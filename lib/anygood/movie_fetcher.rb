module AnyGood
  class MovieFetcher

    def self.fetch_by_name_and_year(moviename, year)
      new.fetch_by_name_and_year(moviename, year)
    end

    def fetch_by_name_and_year(moviename, year)
      ratings = fetch_ratings_from_clients_or_cache(moviename, year)
      info    = fetch_info_from_rottentomatoes_or_cache(moviename, year)

      Movie.new(
        name: moviename.gsub('%20', ' '),
        ratings: ratings,
        info: info
      )
    end

    private

      def fetch_ratings_from_clients_or_cache(moviename, year)
        fetched_ratings = {}

        clients.each do |klass|
          begin
            rating = klass.fetch(moviename, year).rating
          rescue JSON::ParserError
            rating = {error: 'Could not be parsed'}
          end
          fetched_ratings[klass.name] = rating
        end

        fetched_ratings
      end

      def fetch_info_from_rottentomatoes_or_cache(moviename, year)
        ::RottenTomatoes::Client.fetch(moviename, year).info
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
