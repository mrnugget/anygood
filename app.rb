module AnyGood
  class App < Sinatra::Base

    configure do
      AnyGood::REDIS = Redis.new
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
