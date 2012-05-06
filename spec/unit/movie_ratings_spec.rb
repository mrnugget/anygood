require 'spec_helper'

describe AnyGood::MovieRatings do
  it 'allows me to get imdb ratings for a movie' do
    inception_ratings = AnyGood::MovieRatings.find_by_name('Inception')
    inception_ratings.imdb.should == '8.8'
  end

  it 'allows me to get rotten tomatoes ratings for movie' do
    inception_ratings = AnyGood::MovieRatings.find_by_name('Inception')
    inception_ratings.rottentomatoes['critics_score'].should == 86
    inception_ratings.rottentomatoes['audience_score'].should == 93
  end
end
