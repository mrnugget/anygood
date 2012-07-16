require 'spec_helper'

describe AnyGood::MovieFetcher do
  describe '.fetch_by_name_and_year' do
    before(:each) do
      @rating              = {name: 'rating_client', score: 8.0, url: 'www.one.com'}
      rating_client_result = stub(:rating_client_result, rating: @rating)
      @rating_client       = stub(:rating_client, name: 'rating_client', fetch: rating_client_result)

      @movie_info        = {poster: 'www.posterurl.com/pic.jpg'}
      info_client_result = stub(:info_client_result, info: @movie_info)
      @info_client       = stub(:info_client, name: 'info_client', fetch: info_client_result)

      @cache = stub(:cache, get: nil, write: nil)

      @movie_fetcher = AnyGood::MovieFetcher.new
      @movie_fetcher.rating_clients = [@rating_client]
      @movie_fetcher.info_client    = @info_client
      @movie_fetcher.cache          = @cache
    end

    it 'returns an movie object with the right attributes' do
      movie = @movie_fetcher.fetch_by_name_and_year('Inception', 2010)

      movie.should be_a(AnyGood::Movie)
      movie.ratings.first[:name].should == 'rating_client'
      movie.ratings.first[:url].should == 'www.one.com'
      movie.ratings.first[:score].should eq(8.0)
      movie.info[:poster].should == 'www.posterurl.com/pic.jpg'
      movie.combined_rating.should eq(8.0)
    end

    it 'checks the cache before fetching through the clients' do
      @cache.should_receive(:get).exactly(2).times

      @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
    end

    context 'cache is empty' do
      it 'fetches the movie ratings and info through the clients' do
        @rating_client.should_receive(:fetch)
        @info_client.should_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'fetches ratings from all rating clients' do
        second_rating_client_rating = {name: 'second_rating_client', score: 4.0, url: 'www.two.com'}
        second_rating_client_result = stub(:second_rating_client_result, rating: second_rating_client_rating)
        second_rating_client        = stub(:second_rating_client, name: 'second_rating_client', fetch: second_rating_client_result)

        @movie_fetcher.rating_clients = [@rating_client, second_rating_client]

        @rating_client.should_receive(:fetch)
        second_rating_client.should_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end

      it 'writes the fetched client results into the cache' do
        @cache.should_receive(:write).with(:rating, 'Inception', 2010, 'rating_client', @rating)
        @cache.should_receive(:write).with(:info, 'Inception', 2010, 'info_client', @movie_info)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end

    context 'cache is filled' do
      before(:each) do
        @cache.stub(get: :cached_result)
      end

      it 'does not fetch via the clients' do
        @rating_client.should_not_receive(:fetch)
        @info_client.should_not_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end

    context 'only the movieinfo is written to the cache' do
      it 'still fetches the ratings via the rating clients' do
        @cache.should_receive(:get).with(:info, 'Inception', 2010, 'info_client').and_return(:cached_info)
        @cache.should_receive(:get).with(:rating, 'Inception', 2010, 'rating_client').and_return(nil)

        @rating_client.should_receive(:fetch)
        @info_client.should_not_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end

    context 'only the ratings are written to the cache' do
      it 'still fetches the movie info via the info client' do
        @cache.should_receive(:get).with(:rating, 'Inception', 2010, 'rating_client').and_return(:cached_result)
        @cache.should_receive(:get).with(:info, 'Inception', 2010, 'info_client').and_return(nil)

        @info_client.should_receive(:fetch)
        @rating_client.should_not_receive(:fetch)

        @movie_fetcher.fetch_by_name_and_year('Inception', 2010)
      end
    end
  end
end
