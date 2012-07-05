module AnyGood
  class MovieFetcher

    CLIENTS = [Clients::IMDB, Clients::RottenTomatoes]
    CACHE_TTL = 14400

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
      @cache   = cache
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
        key = send("#{type.to_s}_key_for", moviename, client.name)
        get_from_cache(key) || fetch_and_save_to_cache(type, client, moviename, year)
      end

      def fetch_and_save_to_cache(type, client, moviename, year)
        result = client.fetch(moviename, year).send(type)
        key    = send("#{type.to_s}_key_for", moviename, client.name)

        @cache.setex(key, CACHE_TTL, result.to_json)

        result
      end

      def get_from_cache(key)
        cached = @cache.get(key)
        cached ? JSON.parse(cached, symbolize_names: true) : cached
      end

      def info_key_for(moviename, client_name)
        "movieinfo:#{URI.encode(moviename)}:#{URI.encode(client_name)}"
      end

      def rating_key_for(moviename, client_name)
        "movierating:#{URI.encode(moviename)}:#{URI.encode(client_name)}"
      end
  end
end
