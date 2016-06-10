# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

module Environment
  Test = "test".freeze
  Production = "production".freeze
  Development = "development".freeze
  All = [Test, Development, Production].freeze

  # Mapping of environment to the respective override file
  DockerComposeMapping = Hash.new { |_h, k| raise "Unknown Environment #{k}" }
  DockerComposeMapping[Test] = "docker-compose.test.yml"
  DockerComposeMapping[Development] = "docker-compose.dev.yml"

  def self.parse(args)
    environment = args["environment"] || Development
    raise "#{args['environment']} is not a valid environment" unless All.include? environment
    environment
  end

  def self.docker_compose_override_for_environment(env)
    DockerComposeMapping[env]
  end
end

namespace :docker do
  UserService = 'user_service'.freeze
  task :start, :environment do |_t, args|
    environment = Environment.parse(args)
    Rake::Task["docker:build"].invoke(environment)
    override_file = Environment.docker_compose_override_for_environment(environment)
    sh "docker-compose -f docker-compose.yml -f #{override_file} up -d"
    Rake::Task["docker:setup"].invoke(environment)
  end

  task :build, :environment do |_t, _args|
    sh "docker-compose build"
  end

  task :setup do
    # Database set-up
    loop do
      begin sh "docker exec userservice_user_service_1 bundle exec rake db:create db:migrate"
      rescue
        sleep 0.1
      else
        break
      end
    end
  end

  task :test, :environment do |_t, args|
    environment = Environment.parse(args)
    Rake::Task["docker:start"].invoke(environment)
    sh "docker exec userservice_user_service_1 bundle exec rubocop"
    sh "docker exec userservice_user_service_1 bundle exec rspec"
  end
end
