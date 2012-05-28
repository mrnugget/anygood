require 'spec_helper'

describe RottenTomatoes::Client do

  it 'should return its name' do
    RottenTomatoes::Client.name.should == 'Rotten Tomatoes'
  end

  describe 'fetching a movie rating' do
    before(:each) do
      @rating = RottenTomatoes::Client.fetch('Inception', 2010).rating
    end

    it 'fetches the rating of a movie' do
      @rating[:score].should == 8.95
    end

    it 'includes the name of the client' do
      @rating[:url].should == 'http://www.rottentomatoes.com/m/inception/'
    end
  end

  describe 'movie information' do
    it 'fetches the poster for the movie' do
      poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'

      RottenTomatoes::Client.fetch('Inception', 2010).info[:poster].should == poster_url
    end

    it 'fetches the year for the movie' do
      year = 2010

      RottenTomatoes::Client.fetch('Inception', 2010).info[:year].should == year
    end
  end

  describe 'with more than one query result' do
    it 'should return movie matching the criteria' do
      mock_response_for(RottenTomatoes::Client, 'rt_goodbadandugly.json')

      rating = RottenTomatoes::Client.fetch('Good,%20Bad%20and%20the%20ugly', 1966).rating
      rating[:score].should == 9.5
    end
  end
end
