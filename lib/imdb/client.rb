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
      {
        score: @data['imdbRating'].to_f,
        url: "http://www.imdb.com/title/" + @data['imdbID']
      }
    end

    private

      def fetch_data
        JSON.parse(query_api)
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
