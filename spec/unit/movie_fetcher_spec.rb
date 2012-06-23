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

    describe 'caching client results' do
      it 'saves the clients results to database when not in cache already' do
        AnyGood::REDIS.should_receive(:setex).with(
          "movierating:#{URI.encode('Inception')}:#{URI.encode('IMDB')}",
          14400,
          {score: 8.8, url: 'http://www.imdb.com/title/tt1375666'}.to_json
        )
        AnyGood::REDIS.should_receive(:setex).with(
          "movierating:#{URI.encode('Inception')}:#{URI.encode('Rotten Tomatoes')}",
          14400,
          {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}.to_json
        )

        AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'checks the cache before fetching via clients' do
        AnyGood::REDIS.should_receive(:get).with(
          "movierating:#{URI.encode('Inception')}:#{URI.encode('IMDB')}"
        )
        AnyGood::REDIS.should_receive(:get).with(
          "movierating:#{URI.encode('Inception')}:#{URI.encode('Rotten Tomatoes')}"
        )

        AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'does not fetch ratings via clients when the rating is already in cache' do
        AnyGood::REDIS.set(
          "movierating:#{URI.encode('Inception')}:#{URI.encode('IMDB')}",
          {score: 9.0, url: 'example.org'}.to_json
        )

        AnyGood::Clients::IMDB.should_not_receive(:fetch)

        AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'fetches the movieinfo from RT even if RT rating is in cache' do
        AnyGood::REDIS.set(
          "movierating:#{URI.encode('Inception')}:#{URI.encode('Rotten Tomatoes')}",
          {score: 9.0, url: 'example.org'}.to_json
        )

        AnyGood::Clients::RottenTomatoes.should_receive(:fetch).once {
          stub(:rt).as_null_object
        }

        AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'does not fetch the movieinfo from RT if it is in the cache' do
        AnyGood::REDIS.set(
          "movieinfo:#{URI.encode('Inception')}:#{URI.encode('Rotten Tomatoes')}",
          {
            poster: 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg',
            year: 2010
          }.to_json
        )

        AnyGood::Clients::RottenTomatoes.should_receive(:fetch).once {
          stub(:rt).as_null_object
        }

        AnyGood::MovieFetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end
  end
end
