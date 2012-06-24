ENV["RACK_ENV"] ||= "development"

require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

# Dir["./lib/**/*.rb"].each { |f| require f }
require './lib/anygood'
require './app'
