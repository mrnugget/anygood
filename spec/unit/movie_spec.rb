require 'spec_helper'

describe AnyGood::Movie do
  it 'has a combined rating' do
    ratings = [8.0, 8.6]

    inception = AnyGood::Movie.new(
      ratings: ratings
    )

    inception.combined_rating.should == 8.3
  end

  it 'can be converted to JSON' do
    ratings    = [8.0, 8.6]
    info       = RottenTomatoes::Client.fetch('Inception').info

    movie = AnyGood::Movie.new(
      name: 'Inception',
      ratings: ratings,
      info: info
    )
    json_movie = movie.to_json

    poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
    JSON.parse(json_movie)['info']['poster'].should == poster_url
    JSON.parse(json_movie)['name'].should == 'Inception'
  end
end
