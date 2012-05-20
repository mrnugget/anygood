require 'spec_helper'

describe IMDB::Client do
  it 'returns its name' do
    IMDB::Client.name.should == 'IMDB'
  end

  describe 'fetching a movie rating' do
    before(:each) do
      @rating = IMDB::Client.fetch('Inception').rating
    end

    it 'fetches the rating for a movie' do
      @rating[:score].should == 8.8
    end

    it 'includes the URL of the ratings page' do
      @rating[:url].should == 'http://www.imdb.com/title/tt1375666/'
    end
  end
end
