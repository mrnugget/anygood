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

    get '/api/movies/:year/:moviename' do
      content_type :json

      movie = MovieFetcher.fetch_by_name_and_year(
        params[:moviename], params[:year].to_i
      )

      movie.as_json
    end
  end
end
