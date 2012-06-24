require 'spec_helper'

describe AnyGood::MovieImporter do
  describe 'Importing movies from 2004 until 2012' do
    before(:each) do
      stub_http_request(
        :get, 'http://en.wikipedia.org/wiki/2011_in_film'
      ).to_return(
        body: File.read("./spec/fixtures/2011_in_film.html")
      )
    end

    it 'fetches a wikipedia site with a movielist for the given year' do
      movie_importer = AnyGood::MovieImporter.new(2011)

      movie_importer.fetch_movies

      a_request(
        :get, 'http://en.wikipedia.org/wiki/2011_in_film'
      ).should have_been_made
    end

    it 'returns a list of movies from that year' do
      movie_importer = AnyGood::MovieImporter.new(2011)

      movie_list = movie_importer.fetch_movies

      movie_list.should include('Rango', 'The Lincoln Lawyer', 'Crazy, Stupid, Love.')
      movie_list.should_not include('Airplane!', 'West Side Story', 'Kindergarten Cop')
    end

    it 'should not contain duplicates' do
      movie_importer = AnyGood::MovieImporter.new(2011)

      movie_list = movie_importer.fetch_movies

      movie_list.count.should eq(movie_list.uniq.count)
    end
  end
end
