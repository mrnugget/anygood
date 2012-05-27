require 'spec_helper'

describe AnyGood::MovieFetcher do
  describe 'fetch_by_name' do
    it 'returns a Movie object with attributes fetched from different clients' do
      movie = AnyGood::MovieFetcher.fetch_by_name('Inception')

      movie.ratings['IMDB'][:score].should == 8.8
      movie.ratings['Rotten Tomatoes'][:score].should == 8.95
    end

    it 'returns an appropriate message if one of the clients response could not be parsed' do
      mock_response_for(RottenTomatoes::Client, 'json_parse_error.json')

      movie = AnyGood::MovieFetcher.fetch_by_name('Inception')

      movie.ratings['Rotten Tomatoes'][:error].should == 'Could not be parsed'
    end

    it 'returns an appropriate message if the info from RT could not be parsed' do
      mock_response_for(RottenTomatoes::Client, 'json_parse_error.json')

      movie = AnyGood::MovieFetcher.fetch_by_name('Inception')
      movie.info[:error].should == 'Could not be parsed'
    end
  end
end
