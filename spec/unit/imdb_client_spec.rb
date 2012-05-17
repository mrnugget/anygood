require 'spec_helper'

describe IMDB::Client do
  before(:each) do
    @rating = IMDB::Client.fetch('Inception').rating
  end

  it 'fetches the rating for a movie' do
    @rating[:score].should == 8.8
  end

  it 'includes the name of the client' do
    @rating[:name].should == 'IMDB'
  end

  it 'includes the URL of the ratings page' do
    @rating[:url].should == 'http://www.imdb.com/title/tt1375666/'
  end
end
