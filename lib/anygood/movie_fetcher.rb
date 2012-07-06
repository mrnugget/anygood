module AnyGood
  class MovieFetcher

    CLIENTS = [Clients::IMDB, Clients::RottenTomatoes]

    def initialize(rating_clients = CLIENTS, info_client = Clients::RottenTomatoes, cache = MovieCache.new)
      @rating_clients = rating_clients
      @info_client    = info_client
      @cache          = cache
    end

    def fetch_by_name_and_year(movie_name, year)
      ratings = ratings_for(movie_name, year)
      info    = info_for(movie_name, year)

      MovieMatcher.new.incr_score_for(name: movie_name, year: year)
      Movie.new(name: movie_name, year: year, ratings: ratings, info: info)
    end

    private

      def info_for(movie_name, year)
        fetch_from_cache_or_client(:info, @info_client, movie_name, year)
      end

      def ratings_for(movie_name, year)
        @rating_clients.inject({}) do |ratings, client|
          ratings[client.name] = fetch_from_cache_or_client(:rating, client, movie_name, year)
          ratings
        end
      end

      def fetch_from_cache_or_client(type, client, movie_name, year)
        @cache.get_or_new(type, movie_name, client.name) do
          client.fetch(movie_name, year).send(type)
        end
      end
  end
end
