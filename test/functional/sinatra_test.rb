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

require 'deployinator/app'

require 'test/unit'
require 'rack/test'

include Deployinator
include Deployinator::Helpers
include Deployinator::Helpers::DeployHelpers
include Deployinator::Helpers::VersionHelpers
include Deployinator::Helpers::PluginHelpers

class SinatraTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Deployinator::DeployinatorApp.new
  end

  def test_it_mentions_github
    # We can do some sinatra testing
    get '/'
    assert last_response.ok?
    assert last_response.body.include?("Deployinator on Github")
  end

  def test_deploy

    # This however is not a sinatra test
    # This is ripped from deployinator/controller.rb's Controller.run
    # Setting up a light stack just to get things going end to end.
    #
    # Running this test generates artifacts. It writes to a run_log as
    # well as to a development.log file.  If the directories for those
    # don't exists these test might fail.

    # require our test stack - the helper is in there too
    require "stacks/sinatra_test"

    # something like our request
    options =  { 
      :stack => 'sinatra_test',
      :stage => "production",
      :method => 'sinatra_test_production'
    }

    # Create an instance of our deploy object
    klass = "#{Mustache.classify("sinatra_test")}Deploy"
    deploy_class = Deployinator::Stacks.const_get("#{klass}")
    
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
