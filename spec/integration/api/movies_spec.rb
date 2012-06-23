require 'spec_helper'

describe '/api/movies' do
  it 'allows me to get information and ratings of a movie as JSON' do
    stub_rottentomatoes_query('Inception', 'rt_inception')
    stub_imdb_query('Inception', 2010, 'imdb_inception')

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'Inception'
    parsed_body['ratings']['Rotten Tomatoes']['score'].should == 8.95
    parsed_body['ratings']['IMDB']['score'].should == 8.8
  end

  it 'does not fail if one clients has a parse error' do
    stub_rottentomatoes_query('Inception', 'rt_inception')
    stub_imdb_query('Inception', 2010, 'json_parse_error')

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['ratings']['IMDB']['error'].should == 'Could not be parsed'
    parsed_body['combined_rating'].should == 8.95
  end

  it 'does not fail if one client can not find the movie matching the criteria' do
    stub_rottentomatoes_query('Inception', 'rt_inception_wrong_year')

    stub_imdb_query('Inception', 2010, 'imdb_inception')

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)

    parsed_body['ratings']['IMDB']['score'].should == 8.8
    parsed_body['combined_rating'].should == 8.8
    parsed_body['ratings']['Rotten Tomatoes']['error'].should == 'Could not be found'
  end

  it 'works with escaped movie names in the url and returns the right moviename' do
    stub_imdb_query("The%20Good,%20The%20Bad%20And%20The%20Ugly", 1966, 'imdb_goodbadandugly')
    stub_rottentomatoes_query('The%20Good,%20The%20Bad%20And%20The%20Ugly', 'rt_goodbadandugly')

    get '/api/movies/1966/The%20Good,%20The%20Bad%20And%20The%20Ugly'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['name'].should == 'The Good, The Bad And The Ugly'
  end

  it 'reconstructs the movie ratings and info from the cache without hitting the network' do
    AnyGood::REDIS.set(
      "movierating:#{URI.encode('Inception')}:#{URI.encode('IMDB')}",
      {score: 9.0, url: 'example.org'}.to_json
    )
    AnyGood::REDIS.set(
      "movierating:#{URI.encode('Inception')}:#{URI.encode('Rotten Tomatoes')}",
      {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}.to_json
    )
    AnyGood::REDIS.set(
      "movieinfo:#{URI.encode('Inception')}:#{URI.encode('Rotten Tomatoes')}",
      {
        poster: 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg',
        year: 2010
      }.to_json
    )

    get '/api/movies/2010/Inception'

    parsed_body = JSON.parse(last_response.body)
    parsed_body['combined_rating'].should == 8.975
    parsed_body['ratings']['IMDB']['url'].should == 'example.org'

    a_request(:get, /www/).should_not have_been_made
  end
end
