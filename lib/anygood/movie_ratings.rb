require 'json'
require 'redis'
require_relative '../imdb/client'
require_relative '../rottentomatoes/client'

module AnyGood
  class MovieRatings
    def self.find_by_name(moviename)
      new(moviename)
    end

    def initialize(moviename)
      @moviename = moviename
      @redis     = Redis.new
    end

    def all
      @all_ratings ||= fetch_all_ratings
    end

    def imdb
      imdb_data = eval(all['imdb'])
      imdb_data["rating"]
    end

    def rottentomatoes
      rottentomatoes_data = eval(all['rottentomatoes'])
      rottentomatoes_data["ratings"]
    end

    private

      def fetch_all_ratings
        key = ratings_key_for(@moviename)

        unless @redis.hgetall(key).empty?
          @redis.hgetall key
        else
          rt_results   = RottenTomatoes::Client.fetch(@moviename)
          imdb_results = IMDB::Client.fetch(@moviename)

          @redis.hset key, "rottentomatoes", rt_results
          @redis.hset key, "imdb", imdb_results

          @redis.hgetall key
        end
      end

      def ratings_key_for(moviename)
        "movie_ratings:#{moviename}"
      end
  end
end
