require 'spec_helper'

describe AnyGood::MovieCache do
  let(:encoded_movie_name) do
    URI.encode('Inception')
  end

  describe '#write' do
    it 'allows to write movie ratings to Redis' do
      encoded_client_name = URI.encode('client_name')

      key     = "movierating:#{encoded_movie_name}:#{encoded_client_name}"
      payload = {name: 'client_name', score: 5}

      AnyGood::REDIS.should_receive(:setex).with(key, 14400, payload.to_json)

      cache = AnyGood::MovieCache.new
      cache.write(:rating, 'Inception', 'client_name', payload)
    end

    it 'allows to write movie information to Redis' do
      encoded_client_name = URI.encode('info_client')

      key     = "movieinfo:#{encoded_movie_name}:#{encoded_client_name}"
      payload = {poster: 'posterurl.com'}

      AnyGood::REDIS.should_receive(:setex).with(key, 14400, payload.to_json)

      cache = AnyGood::MovieCache.new
      cache.write(:info, 'Inception', 'info_client', payload)
    end
  end

  describe '#get' do
    it 'allows to get movie ratings from the cache' do
      encoded_client_name = URI.encode('client_name')

      key = "movierating:#{encoded_movie_name}:#{encoded_client_name}"

      AnyGood::REDIS.should_receive(:get).with(key)

      cache = AnyGood::MovieCache.new
      cache.get(:rating, 'Inception', 'client_name')
    end

    it 'allows to get movie information from the cache' do
      encoded_client_name = URI.encode('info_client')

      key = "movieinfo:#{encoded_movie_name}:#{encoded_client_name}"

      AnyGood::REDIS.should_receive(:get).with(key)

      cache = AnyGood::MovieCache.new
      cache.get(:info, 'Inception', 'info_client')
    end

    it 'parses the JSON saved to Redis' do
      encoded_client_name = URI.encode('info_client')
      key                 = "movieinfo:#{encoded_movie_name}:#{encoded_client_name}"
      json_string         = {poster: 'www.posterurl.com'}.to_json

      AnyGood::REDIS.set(key, json_string)

      cache = AnyGood::MovieCache.new
      response = cache.get(:info, 'Inception', 'info_client')
      response[:poster].should == 'www.posterurl.com'
    end
  end
end
