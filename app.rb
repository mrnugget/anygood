require 'rubygems'
require 'sinatra'
require 'redis'
require 'json'

require './lib/imdb/client'
require './lib/rottentomatoes/client'
require './lib/anygood/movie_ratings'

class RatingsApp < Sinatra::Base
  get '/' do
    erb :index
  end
  get '/api/ratings/:moviename' do
    ratings = AnyGood::MovieRatings.find_by_name(params[:moviename])
    ratings.all.to_json
  end

  get '/api/ratings/:moviename/imdb' do
    ratings = AnyGood::MovieRatings.find_by_name(params[:moviename])
    ratings.imdb.to_json
  end

  get '/api/ratings/:moviename/rottentomatoes' do
    ratings = AnyGood::MovieRatings.find_by_name(params[:moviename])
    ratings.rottentomatoes.to_json
  end
end
