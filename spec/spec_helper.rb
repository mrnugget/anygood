require './lib/anygood/movie'
require './lib/anygood/movie_fetcher'
require './lib/imdb/client'
require './lib/rottentomatoes/client'
require 'redis'

# Make REDIS available for the unit tests
module AnyGood
  REDIS = Redis.new
end
RSpec.configure do |config|
  config.before(:each) do
    # Monkey-patching the class, so it doesn't hit the network
    # and loads the manually downloaded .json file

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
