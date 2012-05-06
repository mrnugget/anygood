require 'json'
require 'open-uri'

module RottenTomatoes
  class Client
    def self.fetch(moviename)
      new.fetch(moviename)
    end

    def fetch(moviename)
      results = JSON.parse get(moviename)
      results['movies'].first || nil
    end

    private

      def get(moviename)
        api_key = 'art7wzby22d4vmxfs9zw4qjh'
        open("http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{api_key}&q=#{moviename}&page_limit=1").read
      end
  end
end
