module AnyGood
  class MovieFetcher

    def self.fetch_by_name(moviename)
      new.fetch_by_name(moviename)
    end

    def fetch_by_name(moviename)
      ratings = fetch_ratings_from_clients_or_cache(moviename)
      info    = fetch_info_from_rottentomatoes_or_cache(moviename)

      Movie.new(name: moviename, ratings: ratings, info: info)
    end

    private

      def fetch_ratings_from_clients_or_cache(moviename)
        fetched_ratings = {}

        clients.each do |klass|
          begin
            rating = klass.fetch(moviename).rating
          rescue JSON::ParserError
            rating = {error: 'Could not be parsed'}
          end
          fetched_ratings[klass.name] = rating
        end

        fetched_ratings
      end

      def fetch_info_from_rottentomatoes_or_cache(moviename)
        ::RottenTomatoes::Client.fetch(moviename).info
      rescue JSON::ParserError
        {error: 'Could not be parsed'}
      end

      def clients
        [
          ::IMDB::Client,
          ::RottenTomatoes::Client,
        ]
      end
  end
end
