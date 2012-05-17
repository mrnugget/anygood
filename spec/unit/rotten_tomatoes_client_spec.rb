require 'spec_helper'

describe RottenTomatoes::Client do
  it 'fetches the rating of a movie' do
    RottenTomatoes::Client.fetch('Inception').rating.should == 8.95
  end
end
