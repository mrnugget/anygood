Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }
require 'rubygems'
require 'sinatra'
require 'redis'
require 'json'

module AnyGood
  class App < Sinatra::Base

    configure do
      AnyGood::REDIS = Redis.new
    end

    get '/' do
      erb :index
    end

    get '/api/movies/:moviename' do
      content_type :json

      movie = MovieFetcher.fetch_by_name(params[:moviename])
      movie.to_json
    end
  end
end
