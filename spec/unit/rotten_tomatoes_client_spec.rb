require 'spec_helper'

describe AnyGood::Clients::RottenTomatoes do
  before(:each) do
    stub_rottentomatoes_query('Inception', 'rt_inception')
  end

  describe '.name' do
    it 'should return its name' do
      AnyGood::Clients::RottenTomatoes.name.should == 'Rotten Tomatoes'
    end
  end

  describe '.fetch' do
    it 'fetches the JSON data for the specified movie from the API' do
      AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)

      a_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
      ).with(
        :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
      ).should have_been_made
    end

    it 'returns a new client object' do
      object = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)

      object.should be_a(AnyGood::Clients::RottenTomatoes)
    end

    it 'works with movienames including whitespaces and special characters' do
      stub_rottentomatoes_query('The%20Good,%20The%20Bad%20And%20The%20Ugly', 'rt_goodbadandugly')

      AnyGood::Clients::RottenTomatoes.fetch('The Good, The Bad And The Ugly', 1966)

      a_request(
        :get, rottentomatoes_api_url + "The%20Good,%20The%20Bad%20And%20The%20Ugly"
      ).should have_been_made
    end

    context 'the API returns more than one result' do
      it 'should return the movie matching the criteria' do
        stub_rottentomatoes_query('The%20Good,%20The%20Bad%20And%20The%20Ugly', 'rt_goodbadandugly')

        rt_client = AnyGood::Clients::RottenTomatoes.fetch('The Good, The Bad And The Ugly', 1966)
        rt_client.rating[:score].should == 9.5
      end
    end
  end

  describe '#rating' do
    it 'represents the rating of the specified movie' do
      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)

      rt_client.rating[:score].should == 8.95
      rt_client.rating[:url].should == 'http://www.rottentomatoes.com/m/inception/'
    end
  end

  describe '#info' do
    it 'fetches the poster for the movie' do
      poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'

      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)

      rt_client.info[:poster].should == poster_url
    end

    it 'fetches the year for the movie' do
      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)

      rt_client.info[:year].should == 2010
    end
  end
end
