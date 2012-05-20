require 'spec_helper'

describe 'API' do
  it 'allows me to get information and ratings of a movie as JSON' do
    get '/api/movies/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body["name"].should == 'Inception'
  end
end
