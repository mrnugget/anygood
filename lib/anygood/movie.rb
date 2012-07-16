module AnyGood
  class Movie
    attr_accessor :name, :year, :ratings, :info

    def initialize(attributes = {})
      attributes.each do |k, v|
        send "#{k}=", v
      end
    end

    def combined_rating
      scores = @ratings.map {|rating| rating[:score]}.compact
      scores.select! {|score| score > 0 }
      scores.inject(:+) / scores.length
    end

    def as_json(options={})
      JSON.pretty_generate({
        name: @name.sub(/\+/, ' '),
        year: @year,
        info: @info,
        ratings: @ratings,
        combined_rating: combined_rating
      })
    end
  end
end
