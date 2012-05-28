require 'spec_helper'

describe 'API' do
  it 'allows me to get information and ratings of a movie as JSON' do
    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'Inception'
    parsed_body['ratings']['Rotten Tomatoes']['score'].should == 8.95
    parsed_body['ratings']['IMDB']['score'].should == 8.8
  end

  it 'does not fail if one clients has a parse error' do
    mock_response_for(IMDB::Client, 'json_parse_error.json')

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['ratings']['IMDB']['error'].should == 'Could not be parsed'
    parsed_body['combined_rating'].should == 8.95
  end

  it 'works with escaped movie names in the url and returns right moviename' do
    mock_response_for(IMDB::Client, 'imdb_goodbadandugly.json')
    mock_response_for(RottenTomatoes::Client, 'rt_goodbadandugly.json')

    get '/api/movies/1966/The%20Good,%20The%20Bad%20And%20The%20Ugly'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'The Good, The Bad And The Ugly'
  end
end
