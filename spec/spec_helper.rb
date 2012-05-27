ENV['RACK_ENV'] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

# custom macros in spec/support/ and subdirs
Dir[File.expand_path(File.dirname(__FILE__) + '/support/**/*.rb')].each {|f| require f}

def app
  @app ||= AnyGood::App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.before(:each) do
    # Monkey-patching the clients, so they don't hit the network
    # and load the manually downloaded .json file
    mock_response_for(IMDB::Client, 'imdb_inception.json')
    mock_response_for(RottenTomatoes::Client, 'rt_inception.json')
  end
end
