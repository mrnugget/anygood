require 'spec_helper'

describe RottenTomatoes::Client do
  before(:each) do
    stub_http_request(
      :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
    ).with(
      :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
    ).to_return(
      body: File.read('./spec/fixtures/rt_inception.json')
    )
  end

  describe '.name' do
    it 'should return its name' do
      RottenTomatoes::Client.name.should == 'Rotten Tomatoes'
    end
  end

  describe '.fetch' do
    it 'fetches the JSON data for the specified movie from the API' do
      RottenTomatoes::Client.fetch('Inception', 2010)

      a_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json"
      ).with(
        :query => {"apikey" => 'art7wzby22d4vmxfs9zw4qjh', 'q' => 'Inception' }
      ).should have_been_made
    end

    it 'returns a new client object' do
      object = RottenTomatoes::Client.fetch('Inception', 2010)

      object.should be_a(RottenTomatoes::Client)
    end

    it 'works with movienames including whitespaces and special characters' do
      stub_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=art7wzby22d4vmxfs9zw4qjh&q=The%20Good,%20The%20Bad%20And%20The%20Ugly").
       to_return(
         body: File.read('./spec/fixtures/rt_goodbadandugly.json')
      )

      RottenTomatoes::Client.fetch('The Good, The Bad And The Ugly', 1966)

      a_request(
        :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=art7wzby22d4vmxfs9zw4qjh&q=The%20Good,%20The%20Bad%20And%20The%20Ugly"
      ).should have_been_made
    end

    context 'the API returns more than one result' do
      it 'should return the movie matching the criteria' do
        stub_request(
          :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=art7wzby22d4vmxfs9zw4qjh&q=The%20Good,%20The%20Bad%20And%20The%20Ugly").
         to_return(
           body: File.read('./spec/fixtures/rt_goodbadandugly.json')
        )
        rt_client = RottenTomatoes::Client.fetch('The Good, The Bad And The Ugly', 1966)
        rt_client.rating[:score].should == 9.5
      end
    end
  end

  describe '#rating' do
    it 'represents the rating of the specified movie' do
      rt_client = RottenTomatoes::Client.fetch('Inception', 2010)

      rt_client.rating[:score].should == 8.95
      rt_client.rating[:url].should == 'http://www.rottentomatoes.com/m/inception/'
    end
  end

  describe '#info' do
    it 'fetches the poster for the movie' do
      poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'

      rt_client = RottenTomatoes::Client.fetch('Inception', 2010)

      rt_client.info[:poster].should == poster_url
    end

    it 'fetches the year for the movie' do
      rt_client = RottenTomatoes::Client.fetch('Inception', 2010)

      rt_client.info[:year].should == 2010
    end
  end
end
