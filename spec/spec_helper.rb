ENV['RACK_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

def app
  @app ||= AnyGood::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) do

    # Monkey-patching the clients, so they don't hit the network
    # and load the manually downloaded .json file
    module IMDB
      class Client
        private
        def get(moviename)
          File.read('./spec/fixtures/imdb_inception.json')
        end
      end
    end

    # Monkey-patching the class, so it doesn't hit the network
    # and loads the manually downloaded .json file
    module RottenTomatoes
      class Client
        private
        def get(moviename)
          File.read('./spec/fixtures/rt_inception.json')
        end
      end
    end
  end
end
