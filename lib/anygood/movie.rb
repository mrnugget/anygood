require 'json'
require 'redis'
require_relative '../imdb/client'
require_relative '../rottentomatoes/client'

module AnyGood
  class Movie
    attr_accessor :name, :ratings, :info

    def initialize(attributes = {})
      attributes.each do |k, v|
        send "#{k}=", v
      end
    end

    def combined_rating
      @ratings.inject(:+) / @ratings.length
    end
  end
end
