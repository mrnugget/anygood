module AnyGood
  module Clients
    class TheMovieDatabase < Client
      def self.name
        'The Movie Database'
      end

      private
        def score
          @score ||= @data['vote_average']
        end

        def url
          "http://www.themoviedb.org/movie/#{@data['id']}"
        end

        def api_key
          ENV.fetch('THE_MOVIE_DATABASE_KEY') { 'key_not_set' }
        end

        def api_url
          "http://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{@movie_name}&year=#{@year}"
        end

        def matching_movie(response)
          response['results'].first
        end
    end
  end
end
