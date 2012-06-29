module AnyGood
  class MovieFetcher

    def self.fetch_by_name_and_year(moviename, year)
      new.fetch_by_name_and_year(moviename, year)
    end

    def fetch_by_name_and_year(moviename, year)
      ratings = ratings_from_cache_or_clients(moviename, year)
      info    = info_from_cache_or_client(Clients::RottenTomatoes, moviename, year)

      MovieMatcher.new.incr_score_for(name: moviename, year: year)
      Movie.new(name: moviename, year: year, ratings: ratings, info: info)
    end

    private

      def clients
        [
          Clients::IMDB,
          Clients::RottenTomatoes,
        ]
      end

      def info_from_cache_or_client(client, moviename, year)
        cached_info = REDIS.get(info_key_for(moviename, client.name))

        unless cached_info
          fetch_and_save_to_cache(:info, Clients::RottenTomatoes, moviename, year)
        else
          JSON.parse(cached_info, symbolize_names: true)
        end
      end

      def ratings_from_cache_or_clients(moviename, year)
        ratings = {}

        clients.each do |client|
          cached_rating = REDIS.get(rating_key_for(moviename, client.name))

          unless cached_rating
            ratings[client.name] = fetch_and_save_to_cache(:rating, client, moviename, year)
          else
            ratings[client.name] = JSON.parse(cached_rating, symbolize_names: true)
          end
        end

        ratings
      end

      def fetch_and_save_to_cache(type, client, moviename, year)
        result = client.fetch(moviename, year).send(type)
        REDIS.setex(
          send("#{type.to_s}_key_for", moviename, client.name),
          14400,
          result.to_json
        )
        result
      end

      def info_key_for(moviename, client_name)
        "movieinfo:#{URI.encode(moviename)}:#{URI.encode(client_name)}"
      end

      def rating_key_for(moviename, client_name)
        "movierating:#{URI.encode(moviename)}:#{URI.encode(client_name)}"
      end
  end
end
