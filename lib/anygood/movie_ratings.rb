require 'redis'
require 'imdb/client'
require 'rottentomatoes/client'

module AnyGood
  class MovieRatings
    def self.find_by_name(moviename)
      new(moviename).ratings
    end

    def initialize(moviename)
      @moviename = moviename
      @redis = Redis.new
    end

    def ratings
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
