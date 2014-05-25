require 'spec_helper'

describe AnyGood::Clients::TheMovieDatabase do
  before(:each) do
    stub_the_movie_database_query('Inception', 2010, 'tmdb_inception')
  end

  describe '.name' do
    it 'returns the name' do
      AnyGood::Clients::TheMovieDatabase.name.should == 'The Movie Database'
    end
  end

  describe '.fetch' do
    it 'fetches the JSON data for the specified movie from the API' do
      AnyGood::Clients::TheMovieDatabase.fetch('Inception', 2010)

      a_request(
        :get, 'http://api.themoviedb.org/3/search/movie'
      ).with(
        :query => {'api_key' => 'key_not_set', 'query' => 'Inception', 'year' => 2010 }
      ).should have_been_made
    end

    it 'returns a new client object' do
      object = AnyGood::Clients::TheMovieDatabase.fetch('Inception', 2010)

      object.should be_a(AnyGood::Clients::TheMovieDatabase)
    end

    it 'works with movienames including whitespaces and special characters' do
      stub_the_movie_database_query("The%20Good,%20The%20Bad%20And%20The%20Ugly", 1966, 'tmdb_goodbadandugly')

      AnyGood::Clients::TheMovieDatabase.fetch('The Good, The Bad And The Ugly', 1966)

      a_request(
        :get, 'http://api.themoviedb.org/3/search/movie?api_key=key_not_set&query=The%20Good,%20The%20Bad%20And%20The%20Ugly&year=1966'
      ).should have_been_made
    end
  end

  describe '#rating' do
    it 'represents the rating of the specified movie' do
      tmdb_client = AnyGood::Clients::TheMovieDatabase.fetch('Inception', 2010)

      tmdb_client.rating[:name].should == 'The Movie Database'
      tmdb_client.rating[:score].should == 7.5
      tmdb_client.rating[:url].should == 'http://www.themoviedb.org/movie/27205'
    end
  end
end
