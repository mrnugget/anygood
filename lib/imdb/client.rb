require 'json'
require 'net/http'

module IMDB
  class Client
    def self.fetch(moviename, year)
      new(moviename, year)
    end

    def self.name
      'IMDB'
    end

    def initialize(moviename, year)
      @moviename = moviename
      @year      = year
      @data      = fetch_data
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

      def found?
        @data && @data[:error].nil?
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
