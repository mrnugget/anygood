require 'json'
require 'open-uri'

module RottenTomatoes
  class Client
    def self.fetch(moviename)
      new(moviename)
    end

    def initialize(moviename)
      @moviename = moviename
      @data      = fetch_data
    end

    def rating
      {
        score: combined_score,
        name: 'Rotten Tomatoes',
        url: @data['links']['alternate']
      }
    end

    def info
      {
        'poster' => @data['posters']['detailed'],
        'year'   => @data['year']
      }
    end

    private

      def fetch_data
        results = JSON.parse get(@moviename)
        results['movies'].first || nil
      end

      def combined_score
        critics  = @data['ratings']['critics_score'].to_f
        audience = @data['ratings']['audience_score'].to_f

        ("%.2f" % (((critics + audience) / 2) * 0.1)).to_f
      end

      def get(moviename)
        api_key = 'art7wzby22d4vmxfs9zw4qjh'
        open("http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{api_key}&q=#{moviename}&page_limit=1").read
      end
  end
end
