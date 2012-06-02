require 'spec_helper'

describe AnyGood::MovieFetcher do
  describe '.fetch_by_name_and_year' do
    before(:each) do
      # IMDB Client
      stub_http_request(
        :get, "http://www.imdbapi.com/"
      ).with(
        :query => {"t" => 'Inception', 'y' => '2010' }
      ).to_return(
        body: File.read('./spec/fixtures/imdb_inception.json')
      )
      # RottenTomatoes Client
      stub_http_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
      ).with(
        :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
      ).to_return(
        body: File.read('./spec/fixtures/rt_inception.json')
      )
    end

    it 'returns a Movie object with attributes fetched from different clients' do
      movie = AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)

      movie.should be_a(AnyGood::Movie)
      movie.ratings['IMDB'][:score].should == 8.8
      movie.ratings['Rotten Tomatoes'][:score].should == 8.95
    end

    it 'returns an appropriate message if one of the clients response could not be parsed' do
      stub_http_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
      ).with(
        :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
      ).to_return(
        body: File.read('./spec/fixtures/json_parse_error.json')
      )

      movie = AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)

      movie.ratings['Rotten Tomatoes'][:error].should == 'Could not be parsed'
    end

    it 'returns an appropriate message if the info from RT could not be parsed' do
      stub_http_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
      ).with(
        :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
      ).to_return(
        body: File.read('./spec/fixtures/json_parse_error.json')
      )

      movie = AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)
      movie.info[:error].should == 'Could not be parsed'
    end
  end
end
