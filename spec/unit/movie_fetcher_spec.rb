require 'spec_helper'

describe AnyGood::MovieFetcher do
  describe '.fetch_by_name_and_year' do
    before(:each) do
      stub_rottentomatoes_query('Inception', 'rt_inception')
      stub_imdb_query('Inception', 2010, 'imdb_inception')

      @movie_fetcher = AnyGood::MovieFetcher.new
    end

    it 'returns a Movie object with attributes fetched from different clients' do
      movie = @movie_fetcher.fetch_by_name_and_year('Inception', 2010)

      movie.should be_a(AnyGood::Movie)
      movie.ratings['IMDB'][:score].should == 8.8
      movie.ratings['Rotten Tomatoes'][:score].should == 8.95
    end

    it 'returns an appropriate message if one of the clients response could not be parsed' do
      stub_rottentomatoes_query('Inception', 'json_parse_error')

      movie = @movie_fetcher.fetch_by_name_and_year('Inception', 2010)

      movie.ratings['Rotten Tomatoes'][:error].should == 'Could not be parsed'
    end

    it 'returns an appropriate message if the info from RT could not be parsed' do
      stub_rottentomatoes_query('Inception', 'json_parse_error')

      movie = @movie_fetcher.fetch_by_name_and_year('Inception', 2010)

      movie.info[:error].should == 'Could not be parsed'
    end

    describe 'caching client results' do
      let(:encoded_movie_name) do
        URI.encode('Inception')
      end

      let(:encoded_rt_name) do
        URI.encode('Rotten Tomatoes')
      end

      let(:encoded_imdb_name) do
        URI.encode('IMDB')
      end

      it 'checks the cache before fetching via clients' do
        AnyGood::REDIS.should_receive(:get).with(
          "movierating:#{encoded_movie_name}:#{encoded_imdb_name}"
        )
        AnyGood::REDIS.should_receive(:get).with(
          "movierating:#{encoded_movie_name}:#{encoded_rt_name}"
        )

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end

      context 'ratings are not in the cache' do
        it 'saves the clients results to cache' do
          AnyGood::REDIS.should_receive(:setex).with(
            "movierating:#{encoded_movie_name}:#{encoded_imdb_name}",
            14400,
            {score: 8.8, url: 'http://www.imdb.com/title/tt1375666'}.to_json
          )
          AnyGood::REDIS.should_receive(:setex).with(
            "movierating:#{encoded_movie_name}:#{encoded_rt_name}",
            14400,
            {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}.to_json
          )

          @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
        end
      end

      context 'ratings are already in the cache' do
        it 'does not fetch ratings via clients when the rating is already in cache' do
          AnyGood::REDIS.set(
            "movierating:#{encoded_movie_name}:#{encoded_imdb_name}",
            {score: 9.0, url: 'example.org'}.to_json
          )

          AnyGood::Clients::IMDB.should_not_receive(:fetch)

          @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
        end

        it 'fetches the movieinfo from RT even if the RT rating is in cache' do
          AnyGood::REDIS.set(
            "movierating:#{encoded_movie_name}:#{encoded_rt_name}",
            {score: 9.0, url: 'example.org'}.to_json
          )

          AnyGood::Clients::RottenTomatoes.should_receive(:fetch).once {
            stub(:rt).as_null_object
          }

          @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
        end
      end

      context 'movieinfo is already in the cache' do
        it 'does not fetch the movieinfo' do
          AnyGood::REDIS.set(
            "movieinfo:#{encoded_movie_name}:#{encoded_rt_name}",
            {
              poster: 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg',
              year: 2010
            }.to_json
          )

          AnyGood::Clients::RottenTomatoes.should_receive(:fetch).once {
            stub(:rt).as_null_object
          }

          @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
        end
      end
    end
  end
end
