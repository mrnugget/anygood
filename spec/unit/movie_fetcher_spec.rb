require 'spec_helper'

describe AnyGood::MovieFetcher do
   it 'returns a Movie object with attributes fetched from different clients' do
     imdb_rating           = 8.8
     rottentomatoes_rating = 8.95
     movie = AnyGood::MovieFetcher.fetch_by_name('Inception')

     movie.ratings.should include(imdb_rating)
     movie.ratings.should include(rottentomatoes_rating)
   end
end
