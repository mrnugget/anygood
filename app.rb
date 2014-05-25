module AnyGood
  class App < Sinatra::Base
    set :root, File.dirname(__FILE__)
    register Sinatra::AssetPack

    assets {
      serve '/js',     from: 'app/js'
      serve '/css',    from: 'app/css'

      js :anygood, '/js/anygood.js', ['/js/app.js']
      css :application, '/css/application.css', ['/css/screen.css']

      js_compression  :uglify
      css_compression :simple
    }

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

    post '/api/search' do
      unless params['movie'] && params['movie']['name'] && params['movie']['year']
        content_type :json
        status 422
        {error: 'You have to provide a name and a year for the movie'}.to_json
      else
        movie_hash = {
          name: params['movie']['name'],
          year: params['movie']['year'].to_i
        }
        movie_matcher = MovieMatcher.new
        movie_matcher.add_movie(movie_hash)
        status 200
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
