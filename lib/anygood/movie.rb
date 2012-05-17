require 'json'
require 'redis'
require_relative '../imdb/client'
require_relative '../rottentomatoes/client'

module AnyGood
  class Movie

    RATING_CLIENTS = {
      imdb:           ::IMDB::Client,
      rottentomatoes: ::RottenTomatoes::Client
    }

    def self.find_by_name(moviename)
      new(moviename)
    end

    def initialize(moviename)
      @moviename = moviename
      @cache     = Redis.new
    end

    def all
      @all_ratings ||= fetch_all_ratings
    end

    private

      def fetch_all_ratings
        ratings = {}

        RATING_CLIENTS.each do |clientname, klass|
          cached_rating = cached_rating_for(@moviename, clientname)
          if cached_rating
            ratings[clientname] = cached_rating
          else
            ratings[clientname] = klass.fetch
            cache_rating(@moviename, clientname, ratings[clientname])
          end
        end

        ratings
      end

      def cache_rating(moviname, clientname, rating)
        key = ratings_key_for(moviename, clientname)
        @redis.set(key, rating)
        @redis.ttl(key, 40000)
      end

      def cached_rating_for(moviename, clientname)
        key = ratings_key_for(moviename, clientname)
        @redis.get(key)
      end

      def ratings_key_for(moviename, clientname)
        "movie_ratings:#{moviename}:#{clientname}"
      end
  end
end
