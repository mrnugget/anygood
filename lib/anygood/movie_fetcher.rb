module AnyGood
  class MovieFetcher

    CLIENTS = [Clients::IMDB, Clients::RottenTomatoes]

    def self.fetch_by_name_and_year(moviename, year)
      new.fetch_by_name_and_year(moviename, year)
    end

    def fetch_by_name_and_year(moviename, year)
      ratings = ratings_for(moviename, year)
      info    = info_for(Clients::RottenTomatoes, moviename, year)

      MovieMatcher.new.incr_score_for(name: moviename, year: year)
      Movie.new(name: moviename, year: year, ratings: ratings, info: info)
    end

    def initialize(cache = REDIS, clients = CLIENTS)
      @cache   = ClientCache.new
      @clients = clients
    end

    private

      def info_for(client, moviename, year)
        fetch_from_cache_or_client(:info, client, moviename, year)
      end

      def ratings_for(moviename, year)
        ratings = {}

        @clients.each do |client|
          ratings[client.name] = fetch_from_cache_or_client(:rating, client, moviename, year)
        end

        ratings
      end

      def fetch_from_cache_or_client(type, client, moviename, year)
        @cache.get(type, moviename, client.name) do
          client.fetch(moviename, year).send(type)
        end
      end
  end
end
