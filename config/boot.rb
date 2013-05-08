$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..'))

ENV['RACK_ENV'] ||= 'development'

require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require 'anygood'
require 'app'
