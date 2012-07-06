require 'spec_helper'

describe AnyGood::MovieFetcher do
  describe '.fetch_by_name_and_year' do
    before(:each) do
      @client_one_rating = {score: 8.0, url: 'www.one.com'}
      client_one_result  = stub(:client_one_result, rating: @client_one_rating )
      @client_one        = stub(:client_one, name: 'client_one', fetch: client_one_result)

      @client_two_rating = {score: 4.0, url: 'www.two.com'}
      client_two_result  = stub(:client_two_result, rating: @client_two_rating)
      @client_two        = stub(:client_two, name: 'client_two', fetch: client_two_result)

      @movie_info        = {poster: 'www.posterurl.com/pic.jpg'}
      info_client_result = stub(:info_client_result, info: @movie_info)
      @info_client       = stub(:info_client, name: 'info_client', fetch: info_client_result)

      @cache = stub(:cache, get: nil).as_null_object

      @movie_fetcher = AnyGood::MovieFetcher.new
      @movie_fetcher.rating_clients = [@client_one, @client_two]
      @movie_fetcher.info_client    = @info_client
      @movie_fetcher.cache          = @cache
    end

    it 'returns an movie object with the right attributes' do
      movie = @movie_fetcher.fetch_by_name_and_year('Inception', 2010)

      movie.should be_a(AnyGood::Movie)
      movie.ratings['client_one'][:url].should == 'www.one.com'
      movie.ratings['client_one'][:score].should eq(8.0)
      movie.ratings['client_two'][:url].should == 'www.two.com'
      movie.ratings['client_two'][:score].should eq(4.0)
      movie.info[:poster].should == 'www.posterurl.com/pic.jpg'
      movie.combined_rating.should eq(6.0)
    end

    it 'checks the cache before fetching through the clients' do
      @cache.should_receive(:get).exactly(3).times

      @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
    end

    context 'cache is empty' do
      it 'fetches the movie ratings and info through the clients' do
        @client_one.should_receive(:fetch)
        @client_two.should_receive(:fetch)
        @info_client.should_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'writes the fetched client results into the cache' do
        @cache.should_receive(:write).with(:rating, 'Inception', 'client_one', @client_one_rating)
        @cache.should_receive(:write).with(:rating, 'Inception', 'client_two', @client_two_rating)

        @cache.should_receive(:write).with(:info, 'Inception', 'info_client', @movie_info)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end

    context 'cache is filled' do
      before(:each) do
        @cache.stub(get: :cached_result)
      end

      it 'fetches the results from the cache' do
        @cache.should_receive(:get).exactly(3).times

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'does not fetch via the clients' do
        @client_one.should_not_receive(:fetch)
        @client_two.should_not_receive(:fetch)
        @info_client.should_not_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end

    context 'only the movieinfo is written to the cache' do
      it 'still fetches the ratings via the clients' do
        @cache.should_receive(:get).with(:info, 'Inception', 'info_client').and_return(:cached_info)

        @cache.should_receive(:get).with(:rating, 'Inception', 'client_one').and_return(nil)
        @cache.should_receive(:get).with(:rating, 'Inception', 'client_two').and_return(nil)

        @client_one.should_receive(:fetch)
        @client_two.should_receive(:fetch)
        @info_client.should_not_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end

    context 'only the ratings are written to the cache' do
      it 'still fetches the movie info via the info client' do
        @cache.should_receive(:get).with(:rating, 'Inception', 'client_one').and_return(:cached_result)
        @cache.should_receive(:get).with(:rating, 'Inception', 'client_two').and_return(:cached_result)

        @cache.should_receive(:get).with(:info, 'Inception', 'info_client').and_return(nil)

        @info_client.should_receive(:fetch)

        @client_one.should_not_receive(:fetch)
        @client_two.should_not_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end
  end
end
