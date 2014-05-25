module AnyGood
  class MovieFetcher
    attr_accessor :cache, :rating_clients, :info_client

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def cache
      @cache ||= MovieCache.new
    end

    def rating_clients
      @rating_clients ||= [Clients::RottenTomatoes, Clients::TheMovieDatabase]
    end

    def info_client
      @info_client ||= Clients::RottenTomatoes
    end

    def fetch_by_name_and_year(movie_name, movie_year)
      ratings = ratings_for(movie_name, movie_year)
      info    = info_for(movie_name, movie_year)

      MovieMatcher.new.incr_score_for(name: movie_name, year: movie_year)
      Movie.new(name: movie_name, year: movie_year, ratings: ratings, info: info)
    end

    private

      def info_for(movie_name, movie_year)
        fetch_from_cache_or_client(:info, movie_name, movie_year, self.info_client)
      end

      def ratings_for(movie_name, movie_year)
        self.rating_clients.inject([]) do |ratings, client|
          ratings << fetch_from_cache_or_client(:rating, movie_name, movie_year, client)
          ratings
        end
      end

      def fetch_from_cache_or_client(type, movie_name, movie_year, client)
        get_or_cache(type, movie_name, movie_year, client.name) do
          client.fetch(movie_name, movie_year).send(type)
        end
      end

      def get_or_cache(*args)
        if cached = self.cache.get(*args)
          cached
        else
          payload = yield
          self.cache.write(*args, payload)
          payload
        end
      end
  end
end
