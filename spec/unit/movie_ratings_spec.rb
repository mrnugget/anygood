require 'spec_helper'

describe AnyGood::MovieRatings do
  it 'allows me to get rotten tomatoes ratings for a movie' do
    ratings = AnyGood::MovieRatings.find_by_name('Inception')
    ratings.keys.should include('rottentomatoes')
  end

  it 'allows me to get imdb ratings for movie' do
    ratings = AnyGood::MovieRatings.find_by_name('Inception')
    ratings.keys.should include('imdb')
  end
end
