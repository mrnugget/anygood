module AnyGood
  class MovieFetcher

    CLIENTS = [Clients::IMDB, Clients::RottenTomatoes]

    def self.fetch_by_name_and_year(movie_name, year)
      new.fetch_by_name_and_year(movie_name, year)
    end

    def fetch_by_name_and_year(movie_name, year)
      ratings = ratings_for(movie_name, year)
      info    = info_for(Clients::RottenTomatoes, movie_name, year)

      MovieMatcher.new.incr_score_for(name: movie_name, year: year)
      Movie.new(name: movie_name, year: year, ratings: ratings, info: info)
    end

    def initialize(cache = REDIS, clients = CLIENTS)
      @cache   = MovieCache.new
      @clients = clients
    end

    private

      def info_for(client, movie_name, year)
        fetch_from_cache_or_client(:info, client, movie_name, year)
      end

      def ratings_for(movie_name, year)
        @clients.inject({}) do |ratings, client|
          ratings[client.name] = fetch_from_cache_or_client(:rating, client, movie_name, year)
          ratings
        end
      end

      def fetch_from_cache_or_client(type, client, movie_name, year)
        @cache.get(type, movie_name, client.name) do
          client.fetch(movie_name, year).send(type)
        end
      end
  end
end
