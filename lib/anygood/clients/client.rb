require 'net/http'

module AnyGood
  module Clients
    class Client
      def self.fetch(moviename, year)
        new(moviename, year)
      end

      def initialize(moviename, year)
        @moviename = moviename
        @year      = year
        @data      = fetch_data
      end

      private

        def found?
          @data && @data[:error].nil?
        end
    end
  end
end
