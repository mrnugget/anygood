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
        unless @redis.hgetall("movie_ratings:#{@moviename}").empty?
          @redis.hgetall "movie_ratings:#{@moviename}"
        else
          rt_results   = RottenTomatoes::Client.fetch(@moviename)
          imdb_results = IMDB::Client.fetch(@moviename)

          @redis.hset "movie_ratings:#{@moviename}", "rottentomatoes", rt_results
          @redis.hset "movie_ratings:#{@moviename}", "imdb", imdb_results

          @redis.hgetall "movie_ratings:#{@moviename}"
        end
      end
  end
end
