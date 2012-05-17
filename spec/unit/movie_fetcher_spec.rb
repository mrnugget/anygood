require 'spec_helper'

describe AnyGood::MovieFetcher do
   it 'returns a Movie object with attributes fetched from different clients' do
     imdb_rating           = {score: 8.8, name: 'IMDB', url: 'http://www.imdb.com/title/tt1375666/'}
     rottentomatoes_rating = {score: 8.95, name: 'Rotten Tomatoes', url: 'http://www.rottentomatoes.com/m/inception/'}
     movie = AnyGood::MovieFetcher.fetch_by_name('Inception')

     movie.ratings.should include(imdb_rating)
     movie.ratings.should include(rottentomatoes_rating)
   end
end
