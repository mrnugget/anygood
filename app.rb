require 'rubygems'
require 'sinatra'
require 'redis'
require 'json'

require './lib/imdb/client'

# redis = Redis.new

class RatingsApp < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/api/ratings' do
  end

  get '/api/ratings/:moviename' do
  end

  post '/api/ratings' do
  end

  delete '/api/ratings/:moviename' do
  end
end
