ENV['RACK_ENV'] = 'test'

# to do do this you might have to `mkdir log`
# and also `mkdir run_logs`
# or set up the test env quite a bit better 

# this is an attempt to bring in a whole Deployinator environemt
# for your testing enjoyment

require 'sinatra/base'
require 'mustache/sinatra'

# Some of these needs to come before others
require 'deployinator'
require 'deployinator/controller'
require 'deployinator/helpers'
require 'deployinator/helpers/deploy'
require 'deployinator/helpers/version'
require 'deployinator/helpers/git'
require 'deployinator/helpers/plugin'
require 'deployinator/logging'

require 'deployinator/views/layout'
require 'deployinator/views/index'
require 'deployinator/views/log'
require 'deployinator/views/run_logs'
require 'deployinator/views/log_table'
require 'deployinator/views/deploys_status'

# require 'deployinator/app'

require 'test/unit'
# require 'rack/test'

include Deployinator
include Deployinator::Helpers
include Deployinator::Helpers::DeployHelpers
include Deployinator::Helpers::VersionHelpers
include Deployinator::Helpers::PluginHelpers

# This here jazz lets us see our test stacks.
# This line is not idempotent.
Deployinator.root_dir = Deployinator.root("test")

class DeployinatorTest < Test::Unit::TestCase

    attr_accessor :options

    def setup 
        @options = {
            :username => 'McTesty',
            :stack => 'sinatra_test',
            :stage => "production",
            :method => 'sinatra_test_production'
        }
    end

    def test_deployinator_reads_test_stacks_dir

        # Make sure we can see our test stack
        stack_files = Deployinator.get_stack_files
        assert (stack_files.length > 0)

        stacks = Deployinator.get_stacks
        assert (stacks[0] == "sinatra_test")

        assert Deployinator.log_file?

        assert_equal Deployinator.env, "test"
    end


    def test_setup_stack
        options = @options
        # Create an instance of our deploy object

        # This repeats code from Deployinator::Controller.run
        if Deployinator.get_stacks.include?(options[:stack])
            require "stacks/#{options[:stack]}"
            klass = "#{Mustache.classify(options[:stack])}Deploy"
            deploy_class = Deployinator::Stacks.const_get("#{klass}")
        else
            raise "No such stack #{options[:stack]}"
        end

        deploy_instance = deploy_class.new(options)

        # Register plugins
        deploy_instance.register_plugins(options[:stack])

        # We can send messages to the run_log from here
        deploy_instance.log_and_stream("testing here")

        deploy_instance.raise_event(:deploy_start)

        state = deploy_instance.send(options[:method], options)
        if state.nil? || !state.is_a?(Hash)
            state = {}
        end
        deploy_instance.raise_event(:deploy_end, state)

    end
end
