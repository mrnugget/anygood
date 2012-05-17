require './lib/anygood/movie'
require './lib/imdb/client'
require './lib/rottentomatoes/client'

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
