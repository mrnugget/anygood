require 'rubygems'
require 'sinatra'
require 'redis'
require 'json'

class AnyGood::App < Sinatra::Base
  get '/' do
    erb :index
  end

  get '/api/movies/:moviename' do
    # Get movie and to json
  end
end
