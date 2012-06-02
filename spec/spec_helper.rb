ENV['RACK_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

# custom macros in spec/support/ and subdirs
Dir[File.expand_path(File.dirname(__FILE__) + '/support/**/*.rb')].each {|f| require f}

def app
  @app ||= AnyGood::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
