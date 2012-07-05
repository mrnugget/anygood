module AnyGood
  module Clients
    class IMDB < Client
      def self.name
        'IMDB'
      end

      private

        def api_url
          "http://www.imdbapi.com/?t=#{@movie_name}&y=#{@year}"
        end

        def matching_movie(response)
          if response['Title'].downcase == @movie_name.downcase && response['Year'].to_i == @year
            response
          else
            nil
          end
        end

        def score
          @score ||= @data['imdbRating'].to_f || 0.0
        end

        def url
          @url ||= @data['imdbID'] ? "http://www.imdb.com/title/#{@data['imdbID']}" : ''
        end
    end
  end
end
