require 'spec_helper'

describe 'API' do
  it 'allows me to get information and ratings of a movie as JSON' do
    # IMDB Client
    stub_http_request(
      :get, "http://www.imdbapi.com/"
    ).with(
      :query => {"t" => 'Inception', 'y' => '2010' }
    ).to_return(
      body: File.read('./spec/fixtures/imdb_inception.json')
    )
    # RottenTomatoes Client
    stub_http_request(
      :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
    ).with(
      :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
    ).to_return(
      body: File.read('./spec/fixtures/rt_inception.json')
    )

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'Inception'
    parsed_body['ratings']['Rotten Tomatoes']['score'].should == 8.95
    parsed_body['ratings']['IMDB']['score'].should == 8.8
  end

  it 'does not fail if one clients has a parse error' do
    # RottenTomatoes Client
    stub_http_request(
      :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
    ).with(
      :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
    ).to_return(
      body: File.read('./spec/fixtures/rt_inception.json')
    )
    
    # IMDB Client
    stub_http_request(
      :get, "http://www.imdbapi.com/"
    ).with(
      :query => {"t" => 'Inception', 'y' => '2010' }
    ).to_return(
      body: File.read('./spec/fixtures/json_parse_error.json')
    )

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['ratings']['IMDB']['error'].should == 'Could not be parsed'
    parsed_body['combined_rating'].should == 8.95
  end

  it 'works with escaped movie names in the url and returns the right moviename' do
    stub_request(
      :get, "http://www.imdbapi.com/?t=The%20Good,%20The%20Bad%20And%20The%20Ugly&y=1966"
    ).to_return(
      body: File.read('./spec/fixtures/imdb_goodbadandugly.json')
    )
    stub_request(
      :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=art7wzby22d4vmxfs9zw4qjh&q=The%20Good,%20The%20Bad%20And%20The%20Ugly").
    to_return(
      body: File.read('./spec/fixtures/rt_goodbadandugly.json')
    )

    get '/api/movies/1966/The%20Good,%20The%20Bad%20And%20The%20Ugly'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'The Good, The Bad And The Ugly'
  end
end
