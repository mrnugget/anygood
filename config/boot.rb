ENV["RACK_ENV"] ||= "development"

require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require './lib/anygood'
require './app'
