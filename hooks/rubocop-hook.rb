#!/usr/bin/env ruby
# frozen_string_literal: false
require 'singleton'
require 'fileutils'
# Git Hooks RubocopGitHookCreator
# Responsible for inserting a pre-commit hook that runs rubocop
# against cached files
#
class RubocopGitHookCreator
  include Singleton
  def install_hook
    add_rubocop_pre_commit_hook! if install_hook?
  end

  private

  GIT_DIR = ".git".freeze
  HOOK_PATH = "#{GIT_DIR}/hooks/pre-commit".freeze
  RUBOCOP_CMD = "rubocop-git --cached".freeze
  HOOK_CONTENT = ['#!/bin/sh', RUBOCOP_CMD].join("\n").freeze

  def install_hook?
    git_repo? && !hook_exists?
  end

  def git_repo?
    Dir.exist?(GIT_DIR)
  end

  def hook_exists?
    File.exist?(HOOK_PATH) && file_has_hook?
  end

  def file_has_hook?
    File.readlines(HOOK_PATH).any? { |s| s.include?(RUBOCOP_CMD) }
  end

  def add_rubocop_pre_commit_hook!
    File.delete HOOK_PATH if File.exist?(HOOK_PATH)
    File.open(HOOK_PATH, File::CREAT | File::RDWR) do |f|
      f.write HOOK_CONTENT
      f.flush
    end
    FileUtils.chmod 0755, HOOK_PATH
    puts "Successfully installed rubocop pre-commit hook"
  end
end

RubocopGitHookCreator.instance.install_hook if __FILE__ == $PROGRAM_NAME
