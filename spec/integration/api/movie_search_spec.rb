require 'spec_helper'

describe '/api/search' do
  let(:movie_hash) do
    {
      name: 'The Dark Knight',
      year: 2008
    }
  end

  before(:each) do
    @movie_matcher = AnyGood::MovieMatcher.new
    @movie_matcher.add_movie(movie_hash)
  end

  it 'returns a JSON string with the results' do
    get '/api/search?term=The%20Dark'

    last_response.headers['Content-Type'].should == 'application/json;charset=utf-8'
  end

  it 'returns the movie matching my search term' do
    get '/api/search?term=The%20Dark'

    parsed_body = JSON.parse(last_response.body, symbolize_names: true)
    parsed_body[:search_term].should == 'The Dark'
    parsed_body[:movies].should include(movie_hash)
    parsed_body[:movies].should include(movie_hash)
  end

  it 'returns the movies matching my search term' do
    @movie_matcher.add_movie(name: 'The Dark Knight Rises', year: 2012)

    get '/api/search?term=The%20Dark'

    parsed_body = JSON.parse(last_response.body, symbolize_names: true)
    parsed_body[:movies].should have(2).items
    parsed_body[:movies].should include({name: 'The Dark Knight Rises', year: 2012})
  end

  it 'returns the movies ordered by score' do
    @movie_matcher.add_movie(name: 'The Dark Knight Rises', year: 2012)
    @movie_matcher.incr_score_for(movie_hash)

    get '/api/search?term=The%20Dark'

    parsed_body = JSON.parse(last_response.body, symbolize_names: true)
    parsed_body[:movies].first.should == movie_hash
  end

  it 'returns an empty movies array if nothing is found' do
    get '/api/search?term=Indiana'

    parsed_body = JSON.parse(last_response.body, symbolize_names: true)
    parsed_body[:movies].should have(0).items
  end

  it 'returns an 422 error if no search term is given' do
    get '/api/search'

    last_response.status.should eq(422)
  end
end
