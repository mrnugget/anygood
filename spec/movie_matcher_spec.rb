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
    Digest::MD5.hexdigest(movie_hash[:name])
  end

  describe '.add_movie' do

    it 'saves the movie hash as JSON to a redis hash' do
      AnyGood::REDIS.should_receive(:hset).with(
        'moviesearch:data',
        md5_hash_name,
        movie_hash.to_json
      )

      AnyGood::MovieMatcher.add_movie(movie_hash)
    end

    it 'saves the prefixes of the words in the movie name as sorted sets' do
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:th',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:the',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:da',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:dar',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:dark',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:kn',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:kni',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:knig',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:knigh',0,md5_hash_name)
      AnyGood::REDIS.should_receive(:zadd).with('moviesearch:index:knight',0,md5_hash_name)

      AnyGood::MovieMatcher.add_movie(movie_hash)
    end
  end

  describe '.find_by_prefixes' do
    it 'returns the right movie when passed a matching prefix' do
      AnyGood::MovieMatcher.add_movie(movie_hash)

      AnyGood::MovieMatcher.find_by_prefixes(['dark']).should include(movie_hash)
      AnyGood::MovieMatcher.find_by_prefixes(['kni']).should include(movie_hash)
    end

    it 'returns the right movie when passed matching prefixes' do
      AnyGood::MovieMatcher.add_movie(movie_hash)

      matches = AnyGood::MovieMatcher.find_by_prefixes(['da', 'knight'])
      matches.should include(movie_hash)
    end

    it 'returns all movies when passed prefixes occur in both' do
      dark_knight_rises = movie_hash.merge(name: 'The Dark Knight Rises')
      inception         = movie_hash.merge(name: 'Inception')

      AnyGood::MovieMatcher.add_movie(movie_hash)
      AnyGood::MovieMatcher.add_movie(dark_knight_rises)
      AnyGood::MovieMatcher.add_movie(inception)

      matches = AnyGood::MovieMatcher.find_by_prefixes(['da', 'knight'])

      matches.should have(2).items
      matches.should include(movie_hash, dark_knight_rises)
      matches.should_not include(inception)
    end
  end
end
