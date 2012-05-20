require 'spec_helper'

describe AnyGood::MovieFetcher do
   it 'returns a Movie object with attributes fetched from different clients' do
     imdb_rating           = {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'}
     rottentomatoes_rating = {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
     movie = AnyGood::MovieFetcher.fetch_by_name('Inception')

     movie.ratings['IMDB'][:score].should == 8.8
     movie.ratings['Rotten Tomatoes'][:score].should == 8.95
   end

   it 'returns an appropriate message if one of the clients response could not be parsed' do
     # Monkey-patching this, to produce errors.
     module RottenTomatoes
       class Client
         private
         def get(moviename)
          File.read('./spec/fixtures/json_parse_error.json')
         end
       end
     end

     movie = AnyGood::MovieFetcher.fetch_by_name('Inception')

     movie.ratings['Rotten Tomatoes'][:error].should == 'Could not be parsed'
     movie.info[:error].should == 'Could not be parsed'
   end
end
