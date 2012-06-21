require 'spec_helper'
require 'digest'

describe AnyGood::MovieMatcher do
  let(:movie_hash) do
    {
      name: 'The Dark Knight',
      year: 2008
    }
  end

  let(:md5_hash_name) do
    Digest::MD5.hexdigest(movie_hash[:name] + movie_hash[:year].to_s)
  end

  let(:movie_matcher) do
    AnyGood::MovieMatcher.new
  end

  describe AnyGood::MovieMatcher::Result do

    let(:matching_movies) do
      [movie_hash, movie_hash.merge(name: 'The Dark Knight Rises')]
    end

    describe 'initialize' do
      it 'sets the right attributes' do
        result = AnyGood::MovieMatcher::Result.new('The Dark', matching_movies)

        result.search_term.should == 'The Dark'
        result.movies.should == matching_movies
        result.count.should == 2
      end
    end

    describe '#to_json' do
      it 'represents the result as JSON' do
        result = AnyGood::MovieMatcher::Result.new('The Dark', matching_movies)

        json_result   = result.to_json

        parsed_result = JSON.parse(json_result)
        parsed_result['search_term'].should == 'The Dark'
        parsed_result['movies'].should include({'name' => 'The Dark Knight', 'year' => 2008})
      end
    end
  end

  describe 'initialize' do
    it 'sets the limit accordingly' do
      movie_matcher = AnyGood::MovieMatcher.new(limit: 5)

      movie_matcher.limit.should eq(5)
    end

    it 'sets the default limit when its not specified' do
      movie_matcher = AnyGood::MovieMatcher.new

      movie_matcher.limit.should eq(5)
    end
  end

  describe '#add_movie' do
    it 'saves the movie hash as JSON to a redis hash' do
      AnyGood::REDIS.should_receive(:hset).with(
        'moviesearch:data',
        md5_hash_name,
        movie_hash.to_json
      )

      movie_matcher.add_movie(movie_hash)
    end

    it 'saves the prefixes of the words in the movie name as sorted sets' do
      %w(th the da dar dark kn kni knig knigh knight).each do |prefix|
        AnyGood::REDIS.should_receive(:zadd).with("moviesearch:index:#{prefix}",0,md5_hash_name)
      end

      movie_matcher.add_movie(movie_hash)
    end

    it 'does not reset to the score of a movie to 0 when trying to add it again' do
      movie_matcher.add_movie(movie_hash)
      movie_matcher.incr_score_for(movie_hash)

      %w(th the da dar dark kn kni knig knigh knight).each do |prefix|
        AnyGood::REDIS.should_receive(:zadd).with("moviesearch:index:#{prefix}",1,md5_hash_name)
      end

      movie_matcher.add_movie(movie_hash)
    end
  end

  describe '#find_by_prefixes' do
    it 'returns a MovieMatcher::Result object' do
      movie_matcher.add_movie(movie_hash)

      result = movie_matcher.find_by_prefixes(['dark'])
      result.should be_a(AnyGood::MovieMatcher::Result)
    end

    it 'returns the right movie when passed a matching prefix' do
      movie_matcher.add_movie(movie_hash)

      result = movie_matcher.find_by_prefixes(['dark'])

      result.movies.should include(movie_hash)
    end

    it 'returns the right movie when passed more than one matching prefixe' do
      movie_matcher.add_movie(movie_hash)

      result = movie_matcher.find_by_prefixes(['da', 'knight'])
      result.movies.should include(movie_hash)
    end

    it 'returns all movies when passed prefixes occuring in both' do
      dark_knight_rises = movie_hash.merge(name: 'The Dark Knight Rises')
      inception         = movie_hash.merge(name: 'Inception')

      movie_matcher.add_movie(movie_hash)
      movie_matcher.add_movie(dark_knight_rises)
      movie_matcher.add_movie(inception)

      result = movie_matcher.find_by_prefixes(['da', 'knight'])

      result.count.should == 2
      result.movies.should include(movie_hash, dark_knight_rises)
    end

    it 'does not return movies when passed prefixes dont occur in their names' do
      dark_knight_rises = movie_hash.merge(name: 'The Dark Knight Rises')
      inception         = movie_hash.merge(name: 'Inception')

      movie_matcher.add_movie(movie_hash)
      movie_matcher.add_movie(dark_knight_rises)
      movie_matcher.add_movie(inception)

      result = movie_matcher.find_by_prefixes(['da', 'knight'])

      result.movies.should_not include(inception)
    end

    it 'returns at max the number of movies specified via limit' do
      dark_knight_rises = movie_hash.merge(name: 'The Dark Knight Rises')

      movie_matcher.add_movie(movie_hash)
      movie_matcher.add_movie(dark_knight_rises)
      movie_matcher.limit = 1

      result = movie_matcher.find_by_prefixes(['dark'])

      result.count.should eq(1)
    end

    it 'works case-insensitive when passes prefixes' do
      movie_matcher.add_movie(movie_hash)

      result = movie_matcher.find_by_prefixes(['Da', 'Knight'])
      result.movies.should include(movie_hash)
    end

    it 'sorts the match results after the score of the movies' do
      movie_matcher.add_movie(movie_hash)
      movie_matcher.add_movie(movie_hash.merge(name: 'The Green Mile'))

      movie_matcher.incr_score_for(movie_hash)

      result = movie_matcher.find_by_prefixes(['the'])
      result.movies.first.should == movie_hash
    end

    it 'returns an empty Result object when no movie is found' do
      result = movie_matcher.find_by_prefixes(['not', 'found'])

      result.movies.should be_empty
      result.count.should eq(0)
    end
  end

  describe '#incr_score_for' do
    it 'increments the score of the movies data hash key in the prefix sets' do
      %w(th the da dar dark kn kni knig knigh knight).each do |prefix|
        AnyGood::REDIS.should_receive(:zincrby).with("moviesearch:index:#{prefix}",1,md5_hash_name)
      end

      movie_matcher.incr_score_for(movie_hash)
    end
  end
end
