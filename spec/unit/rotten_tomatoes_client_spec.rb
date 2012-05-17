require 'spec_helper'

describe RottenTomatoes::Client do
  it 'fetches the rating of a movie' do
    RottenTomatoes::Client.fetch('Inception').rating.should == 8.95
  end

  it 'fetches the poster for the movie' do
    poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'

    RottenTomatoes::Client.fetch('Inception').info['poster'].should == poster_url
  end

  it 'fetches the year for the movie' do
    year = 2010

    RottenTomatoes::Client.fetch('Inception').info['year'].should == year
  end
end
