require 'spec_helper'

describe IMDB::Client do
  it 'fetches the rating for a movie' do
    IMDB::Client.fetch('Inception').rating.should == 8.8
  end
end
