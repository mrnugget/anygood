require 'net/http'

module AnyGood
  module Clients
    class Client
      def self.fetch(moviename, year)
        new(moviename, year)
      end

      def rating
        found? ? {score: score, url: url} : @data
      end

      def initialize(moviename, year)
        @moviename = moviename
        @year      = year
        @data      = fetch_data
      end

      private

        def fetch_data
          begin
            response = JSON.parse(query_api)
            matching_movie(response) || {error: 'Could not be found'}
          rescue JSON::ParserError
            {error: 'Could not be parsed'}
          end
        end

        def found?
          @data && @data[:error].nil?
        end

        def query_api
          uri     = URI(URI.encode(api_url))

          response = Net::HTTP.get_response(uri)
          response.body
        end
    end
  end
end
