require 'spec_helper'

describe AnyGood::Movie do
  it 'has a combined rating' do
    ratings = {
      'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
      'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
    }

    inception = AnyGood::Movie.new(ratings: ratings)

    inception.combined_rating.should == 8.875
  end

  it 'can be represented as JSON' do
    stub_http_request(
      :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
    ).with(
      :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
    ).to_return(
      body: File.read('./spec/fixtures/rt_inception.json')
    )

    ratings = {
      'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
      'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
    }

    info = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010).info

    movie = AnyGood::Movie.new(name: 'Inception', ratings: ratings,info: info)
    json_movie = movie.as_json

    poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
    JSON.parse(json_movie)['info']['poster'].should == poster_url
    JSON.parse(json_movie)['name'].should == 'Inception'
  end
end
