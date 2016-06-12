require 'rake'
module Docker
  class Environment
    def self.create(args)
      environment = args["environment"] || Type::Development
      raise "#{args['environment']} is not a valid environment" unless Type::All.include?(environment)
      new_env = new(environment)
      new_env.send(:process_env)
      new_env
    end

    def override_file
      DockerComposeMapping[type]
    end

    attr_accessor :type

    def initialize(type)
      @type = type
    end

    private

    def process_env
      Rake.sh 'rm -rv tmp/* 2> /dev/null; true'
    end

    module Type
      Test = "test".freeze
      Production = "production".freeze
      Development = "development".freeze
      All = [Test, Development, Production].freeze
    end

    # Mapping of environment to the respective override file
    DockerComposeMapping = Hash.new { |_h, k| raise "Unknown Environment #{k}" }
    DockerComposeMapping[Type::Test] = "docker-compose.test.yml"
    DockerComposeMapping[Type::Development] = "docker-compose.dev.yml"
  end
end
