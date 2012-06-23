require 'spec_helper'

describe AnyGood::Clients::IMDB do
  before(:each) do
    stub_http_request(
      :get, "http://www.imdbapi.com/"
    ).with(
      :query => {"t" => 'Inception', 'y' => '2010' }
    ).to_return(
      body: File.read('./spec/fixtures/imdb_inception.json')
    )
  end

  describe '.name' do
    it 'returns its name' do
      AnyGood::Clients::IMDB.name.should == 'IMDB'
    end
  end

  describe '.fetch' do
    it 'fetches the JSON data for the specified movie from the API' do
      AnyGood::Clients::IMDB.fetch('Inception', 2010)

      a_request(
        :get, "http://www.imdbapi.com/"
      ).with(
        :query => {"t" => 'Inception', 'y' => '2010' }
      ).should have_been_made
    end

    it 'returns a new client object' do
      object = AnyGood::Clients::IMDB.fetch('Inception', 2010)

      object.should be_a(AnyGood::Clients::IMDB)
    end

    it 'works with movienames inluding whitespaces and special characters' do
      stub_request(
        :get, "http://www.imdbapi.com/?t=The%20Good,%20The%20Bad%20And%20The%20Ugly&y=1966"
      ).to_return(
        body: File.read('./spec/fixtures/imdb_goodbadandugly.json')
      )


      AnyGood::Clients::IMDB.fetch('The Good, The Bad And The Ugly', 1966)

      a_request(
        :get, "http://www.imdbapi.com/?t=The%20Good,%20The%20Bad%20And%20The%20Ugly&y=1966"
      ).should have_been_made
    end
  end

  describe '#rating' do
    it 'represents the rating of the specified movie' do
      imdb_client = AnyGood::Clients::IMDB.fetch('Inception', 2010)

      imdb_client.rating[:score].should == 8.8
      imdb_client.rating[:url].should == 'http://www.imdb.com/title/tt1375666'
    end
  end
end
