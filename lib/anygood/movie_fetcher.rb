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
      @rating_clients ||= [Clients::IMDB, Clients::RottenTomatoes] 
    end

    def info_client
      @info_client ||= Clients::RottenTomatoes
    end

    def fetch_by_name_and_year(movie_name, year)
      ratings = ratings_for(movie_name, year)
      info    = info_for(movie_name, year)

      MovieMatcher.new.incr_score_for(name: movie_name, year: year)
      Movie.new(name: movie_name, year: year, ratings: ratings, info: info)
    end

    private

      def info_for(movie_name, year)
        fetch_from_cache_or_client(:info, movie_name, year, self.info_client)
      end

      def ratings_for(movie_name, year)
        self.rating_clients.inject([]) do |ratings, client|
          ratings << fetch_from_cache_or_client(:rating, movie_name, year, client)
          ratings
        end
      end

      def fetch_from_cache_or_client(type, movie_name, year, client)
        get_or_cache(type, movie_name, client.name) do
          client.fetch(movie_name, year).send(type)
        end
      end

      def get_or_cache(type, movie_name, client_name)
        if cached = self.cache.get(type, movie_name, client_name)
          cached
        else
          payload = yield
          self.cache.write(type, movie_name, client_name, payload)
          payload
        end
      end
  end
end
