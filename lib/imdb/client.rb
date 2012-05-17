require 'json'
require 'open-uri'

module IMDB
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
        score: @data['rating'].to_f,
        name: 'IMDB',
        url: @data['imdburl']
      }
    end

    private

      def fetch_data
        JSON.parse(get(@moviename))
      end

      def get(moviename)
        open("http://www.deanclatworthy.com/imdb/?type=json&q=#{moviename}").read
      end
  end
end
