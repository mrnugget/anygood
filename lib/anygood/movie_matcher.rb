require 'digest'

module AnyGood
  class MovieMatcher

    def self.add_movie(movie_hash)
      new.add_movie(movie_hash)
    end

    def self.find_by_prefixes(prefixes)
      new.find_by_prefixes(prefixes)
    end

    def find_by_prefixes(prefixes)
      intersection_key = index_key_for(prefixes)
      index_keys       = prefixes.map {|prefix| index_key_for(prefix)}

      REDIS.multi do
        REDIS.zinterstore(intersection_key, index_keys)
        REDIS.expire(intersection_key, 7200)
      end

      data_hash_keys  = REDIS.zrange(intersection_key, 0, -1)
      matching_movies = REDIS.hmget(data_key, *data_hash_keys)

      matching_movies.map {|movie| JSON.parse(movie, symbolize_names: true)}
    end

    def add_movie(movie_hash)
      prefixes    = prefixes_for(movie_hash[:name])
      hashed_name = data_hash_key_for(movie_hash)

      prefixes.each {|prefix| REDIS.zadd(index_key_for(prefix), 0, hashed_name)}

      REDIS.hset(data_key, hashed_name, movie_hash.to_json)
    end

    private

      def data_key
        'moviesearch:data'
      end

      def prefixes_for(string)
        prefixes = []
        words    = string.downcase.split(' ')

        words.each do |word|
          (1..word.length).each {|i| prefixes << word[0...i] unless i == 1}
        end

        prefixes
      end

      def index_key_for(*prefixes)
        "moviesearch:index:#{prefixes.join('|')}"
      end

      def data_hash_key_for(movie_hash)
        Digest::MD5.hexdigest(movie_hash[:name])
      end
  end
end
