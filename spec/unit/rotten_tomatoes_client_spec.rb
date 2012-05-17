require 'spec_helper'

describe RottenTomatoes::Client do
  before(:each) do
    @rating = RottenTomatoes::Client.fetch('Inception').rating
  end

  it 'fetches the rating of a movie' do
    @rating[:score].should == 8.95
  end

  it 'includes the name of the client' do
    @rating[:name].should == 'Rotten Tomatoes'
  end

  it 'includes the name of the client' do
    @rating[:url].should == 'http://www.rottentomatoes.com/m/inception/'
  end

  describe 'movie information' do
    it 'fetches the poster for the movie' do
      poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'

      RottenTomatoes::Client.fetch('Inception').info['poster'].should == poster_url
    end

    it 'fetches the year for the movie' do
      year = 2010

      RottenTomatoes::Client.fetch('Inception').info['year'].should == year
    end
  end
end
