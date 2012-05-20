require 'spec_helper'

describe AnyGood::Movie do
  it 'has a combined rating' do
    ratings = {
      'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
      'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
    }

    inception = AnyGood::Movie.new(
      ratings: ratings
    )

    inception.combined_rating.should == 8.875
  end

  it 'can be represented as JSON' do
    ratings = {
      'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
      'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
    }
    info = RottenTomatoes::Client.fetch('Inception').info

    movie = AnyGood::Movie.new(
      name: 'Inception',
      ratings: ratings,
      info: info
    )
    json_movie = movie.as_json

    poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
    JSON.parse(json_movie)['info']['poster'].should == poster_url
    JSON.parse(json_movie)['name'].should == 'Inception'
  end
end
