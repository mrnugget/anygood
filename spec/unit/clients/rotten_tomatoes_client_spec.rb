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
        :get, 'http://api.rottentomatoes.com/api/public/v1.0/movies.json'
      ).with(
        :query => {'apikey' => 'key_not_set', 'q' => 'Inception' }
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

      rt_client.rating[:name].should == 'Rotten Tomatoes'
      rt_client.rating[:score].should == 8.95
      rt_client.rating[:url].should == 'http://www.rottentomatoes.com/m/inception/'
    end

    it 'ignores a rating that is 0' do
      stub_http_request(
        :get, /api.rottentomatoes.com\/api\/public\/v1\.0\/movies.json/
      ).to_return(
        body: '{
          "total": 1,
          "movies": [
            {
              "title": "Inception",
              "year": 2010,
              "ratings": {
                "critics_rating": "Certified Fresh",
                "critics_score": 0,
                "audience_rating": "Upright",
                "audience_score": 93
              },
              "links": {
                "alternate": "http://www.rottentomatoes.com/m/inception/"
              }
            }
          ]
        }'
      )

      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)
      rt_client.rating[:score].should == 9.3
    end

    it 'returns 0 if both ratings are 0' do
      stub_http_request(
        :get, /api.rottentomatoes.com\/api\/public\/v1\.0\/movies.json/
      ).to_return(
        body: '{
          "total": 1,
          "movies": [
            {
              "title": "Inception",
              "year": 2010,
              "ratings": {
                "critics_rating": "Certified Fresh",
                "critics_score": 0,
                "audience_rating": "Upright",
                "audience_score": 0
              },
              "links": {
                "alternate": "http://www.rottentomatoes.com/m/inception/"
              }
            }
          ]
        }'
      )

      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)
      rt_client.rating[:score].should == 0.0
    end

    it 'does not fail if no ratings are found' do
      stub_http_request(
        :get, /api.rottentomatoes.com\/api\/public\/v1\.0\/movies.json/
      ).to_return(
        body: '{
          "total": 1,
          "movies": [
            {
              "title": "Inception",
              "year": 2010,
              "ratings": {
              },
              "links": {
                "alternate": "http://www.rottentomatoes.com/m/inception/"
              }
            }
          ]
        }'
      )

      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)
      rt_client.rating[:score].should == 0.0
    end
  end

  describe '#info' do
    it 'fetches the poster for the movie' do
      poster_url = 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'

      rt_client = AnyGood::Clients::RottenTomatoes.fetch('Inception', 2010)

      rt_client.info[:poster].should == poster_url
    end
  end
end
