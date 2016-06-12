require_relative 'concerns/container'
require_relative 'concerns/environment'
namespace :docker do
  desc "Starts a running container for a given environment rake start[#{Docker::Environment::Type::All.join(' || ')}]"
  task :start, :environment do |_t, args|
    environment = Docker::Environment.create(args)
    Docker::Container.new(environment).start
  end

  desc "Stop the container for a particular environment rake stop[#{Docker::Environment::Type::All.join(' || ')}]"
  task :stop, :environment do |_t, args|
    environment = Docker::Environment.create(args)
    Docker::Container.new(environment).stop
  end

  desc "Runs code checks in a docker container rake test[#{Docker::Environment::Type::All.join(' || ')}]"
  task :test, :environment do |_t, args|
    environment = Docker::Environment.create(args)
    container = Docker::Container.new(environment)
    container.start
    container.execute 'bundle exec rubocop'
    container.execute 'bundle exec rspec'
  end
end
