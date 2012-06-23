module AnyGood
  module Clients
    class IMDB < Client
      def self.name
        'IMDB'
      end

      def rating
        if found?
          {
            score: @data['imdbRating'].to_f,
            url: "http://www.imdb.com/title/" + @data['imdbID']
          }
        else
          @data
        end
      end

      private

        def fetch_data
          begin
            response = JSON.parse(query_api)
            if response['Title'].downcase == @moviename.downcase && response['Year'].to_i == @year
              response
            else
              {error: 'Could not be found'}
            end
          rescue JSON::ParserError
            {error: 'Could not be parsed'}
          end
        end

        def query_api
          uri = URI(
            URI.encode("http://www.imdbapi.com/?t=#{@moviename}&y=#{@year}")
          )
          response = Net::HTTP.get_response(uri)
          response.body
        end
    end
  end
end
