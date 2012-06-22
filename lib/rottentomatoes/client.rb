require 'json'
require 'net/http'

module RottenTomatoes
  class Client
    def self.fetch(moviename, year)
      new(moviename, year)
    end

    def self.name
      'Rotten Tomatoes'
    end

    def initialize(moviename, year)
      @moviename = moviename
      @year      = year
      @data      = fetch_data
    end

    def rating
      found? ? {score: combined_score, url: @data['links']['alternate']} : @data
    end

    def info
      found? ? {poster: @data['posters']['detailed'], year: @year} : @data
    end

    private

      def fetch_data
        begin
          results         = JSON.parse(query_api)
          matching_movies = results['movies'].select {|movie| movie['year'] == @year}

          matching_movies.first || {error: 'Could not be found'}
        rescue JSON::ParserError
          {error: 'Could not be parsed'}
        end
      end

      def combined_score
        critics  = @data['ratings']['critics_score'].to_f
        audience = @data['ratings']['audience_score'].to_f

        ("%.2f" % (((critics + audience) / 2) * 0.1)).to_f
      end

      def found?
        @data && @data[:error].nil?
      end

      def query_api
        api_key = 'art7wzby22d4vmxfs9zw4qjh'
        uri     = URI(
          URI.encode("http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{api_key}&q=#{@moviename}")
        )

        response = Net::HTTP.get_response(uri)
        response.body
      end
  end
end
