module AnyGood
  class App < Sinatra::Base

    configure do
      if ENV["REDISTOGO_URL"]
        uri = URI.parse(ENV["REDISTOGO_URL"])
        AnyGood::REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        AnyGood::REDIS = Redis.new
      end
    end

    get '/' do
      erb :index
    end

    get '/api/search' do
      content_type :json

      if params[:term]
        movie_matcher = MovieMatcher.new
        result        = movie_matcher.find_by_prefixes(params[:term].split(' '))

        result.to_json
      else
        status 422
        {error: 'You have to provide a term'}.to_json
      end
    end

    get '/api/movies/:year/:name' do
      content_type :json

      movie = MovieFetcher.new.fetch_by_name_and_year(
        params[:name], params[:year].to_i
      )

      movie.as_json
    end
  end
end
