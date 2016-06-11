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

def container_name_for_environment(environment)
  "#{environment}_#{UserServiceName}_1"
end

namespace :docker do
  UserServiceName = 'user_service'.freeze

  desc "Starts a running container for a given environment #{Environment::All.join(', ')}"
  task :start, :environment do |_t, args|
    environment = Environment.parse(args)
    Rake::Task["docker:build"].invoke(environment)
    override_file = Environment.docker_compose_override_for_environment(environment)
    sh "docker-compose -f docker-compose.yml -f #{override_file} -p #{environment} up -d"
    Rake::Task["docker:setup"].invoke(environment)
  end

  desc "Build all the services defined in the docker-compose"
  task :build do
    sh "docker-compose build"
  end

  desc "Set-up task run after containers are started"
  task :setup, :environment do |_t, args|
    environment = Environment.parse(args)
    # Database set-up
    loop do
      begin sh "docker exec #{container_name_for_environment(environment)} bundle exec rake db:create db:migrate"
      rescue
        sleep 0.1
      else
        break
      end
    end
  end

  desc "Stop the container for a particular environment"
  task :stop, :environment do |_t, args|
    environment = Environment.parse(args)
    sh "docker-compose -p #{environment} down"
  end

  desc "Starts a docker container in the #{Environment::Test} environment and runs rubocop, rspec"
  task :test, :environment do |_t, args|
    environment = Environment.parse(args)
    Rake::Task["docker:start"].invoke(environment)
    sh "docker exec #{container_name_for_environment(environment)} bundle exec rubocop"
    sh "docker exec #{container_name_for_environment(environment)} bundle exec rspec"
  end
end
