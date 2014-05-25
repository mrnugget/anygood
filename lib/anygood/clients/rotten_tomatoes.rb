module AnyGood
  module Clients
    class RottenTomatoes < Client
      def self.name
        'Rotten Tomatoes'
      end

      def info
        found? ? {poster: @data['posters']['detailed']} : @data
      end

      private

        def api_url
          api_key = ENV.fetch('ROTTEN_TOMOATES_KEY') { 'key_not_set' }
          "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{api_key}&q=#{@movie_name}"
        end

        def calculate_combined_score
          scores = []

          if @data['ratings']['critics_score'] && @data['ratings']['audience_score']
            scores << @data['ratings']['critics_score'].to_f
            scores << @data['ratings']['audience_score'].to_f
          end

          scores.select! {|score| score > 0.0 }
          scores_sum = scores.inject(:+)

          if scores.any? && scores_sum > 0.0
            ("%.2f" % ((scores_sum / scores.length) * 0.1)).to_f
          else
            0.0
          end
        end

        def matching_movie(response)
          matching_movies = response['movies'].select {|movie| movie['year'] == @year}

          matching_movies.first || nil
        end

        def score
          @score ||= calculate_combined_score
        end

        def url
          @url ||= @data['links']['alternate'] || ''
        end
    end
  end
end
