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


      name = params[:moviename].gsub(' ', '%20')
      movie = MovieFetcher.fetch_by_name_and_year(
        name, params[:year].to_i
      )
      movie.as_json
    end
  end
end
