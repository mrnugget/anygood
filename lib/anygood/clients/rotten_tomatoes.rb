module AnyGood
  module Clients
    class RottenTomatoes < Client
      def self.name
        'Rotten Tomatoes'
      end

      def rating
        found? ? {score: combined_score, url: @data['links']['alternate']} : @data
      end

      def info
        found? ? {poster: @data['posters']['detailed']} : @data
      end

      private

        def fetch_data
          begin
            results         = JSON.parse(query_api)
            matching_movies = results['movies'].select {|movie| movie['year'] == @year}

            matching_movies.first || {error: 'Could not be found'}
          rescue JSON::ParserError
            {error: 'Could not be parsed'}
          end
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

        def combined_score
          @combined_score ||= calculate_combined_score
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
end
