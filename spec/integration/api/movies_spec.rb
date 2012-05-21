require 'spec_helper'

describe 'API' do
  it 'allows me to get information and ratings of a movie as JSON' do
    get '/api/movies/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'Inception'
    parsed_body['ratings']['Rotten Tomatoes']['score'].should == 8.95
    parsed_body['ratings']['IMDB']['score'].should == 8.8
  end

  it 'does not fail if one clients has a parse error' do
    # Monkey-patching this, to produce errors.
    module IMDB
      class Client
        private
        def get(moviename)
          File.read('./spec/fixtures/json_parse_error.json')
        end
      end
    end

    get '/api/movies/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['ratings']['IMDB']['error'].should == 'Could not be parsed'
    parsed_body['combined_rating'].should == 8.95
  end
end
