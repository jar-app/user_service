require 'rake'
module Docker
  class Container
    ServiceName = 'user_service'.freeze
    @@containers = [] # rubocop:disable Style/ClassVars
    attr_accessor :env

    def initialize(environment)
      @state = State::UNKNOWN
      @env = environment
      @@containers << self
    end

    def start
      return if started?
      build
      Rake.sh "docker-compose -f docker-compose.yml -f #{env.override_file} -p #{@env.type} up -d"
      setup
      started!
    end

    def stop
      Rake.sh "docker-compose -p #{@env.type} down"
      stopped!
    end

    def execute(cmd)
      Rake.sh "docker exec #{name} #{cmd}"
    end

    def started?
      @state == State::STARTED
    end

    private

    def build
      Rake.sh 'docker-compose build'
    end

    def name
      "#{@env.type}_#{ServiceName}_1"
    end

    def stopped!
      @state = State::STOPPED
    end

    def started!
      @state = State::STARTED
    end

    def setup
      loop do
        begin
          execute 'bundle exec rake db:create db:migrate'
        rescue
          sleep 0.5
        else
          break
        end
      end
    end

    module State
      UNKNOWN = 0
      STARTED = 1
      STOPPED = -1
    end
  end
end
