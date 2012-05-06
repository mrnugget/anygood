require 'spec_helper'

describe IMDB::Client do
  it 'fetches JSON data for a movie' do
    IMDB::Client.fetch('Inception').keys.length.should > 1
  end
  it 'fetches the rating of a movie' do
    IMDB::Client.fetch('Inception').should include('rating')
  end
end
