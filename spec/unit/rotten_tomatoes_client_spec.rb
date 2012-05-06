require 'spec_helper'

describe RottenTomatoes::Client do
  it 'fetches JSON data for a movie' do
    RottenTomatoes::Client.fetch('Inception').keys.length.should > 1
  end
  it 'fetches the rating of a movie' do
    RottenTomatoes::Client.fetch('Inception').should include('ratings')
  end
end
