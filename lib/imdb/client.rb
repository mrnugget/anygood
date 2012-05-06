require 'json'
require 'open-uri'

module IMDB
  class Client
    def self.fetch(moviename)
      new.fetch moviename
    end

    def fetch(moviename)
      JSON.parse get(moviename)
    end

    private

      def get(moviename)
        open("http://www.deanclatworthy.com/imdb/?type=json&q=#{moviename}").read
      end
  end
end
