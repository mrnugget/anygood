require 'json'
require 'open-uri'
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
      {
        score: combined_score,
        url: @data['links']['alternate']
      }
    end

    def info
      {
        poster:  @data['posters']['detailed'],
        year:    @year
      }
    end

    private

      def fetch_data
        results = JSON.parse(query_api)
        matching_movies = results['movies'].select do |movie|
          movie['year'] == @year
        end
        matching_movies.first || nil
      end

      def combined_score
        critics  = @data['ratings']['critics_score'].to_f
        audience = @data['ratings']['audience_score'].to_f

        ("%.2f" % (((critics + audience) / 2) * 0.1)).to_f
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
