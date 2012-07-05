module AnyGood
  class MovieCache

    TTL = 14400

    def get(type, movie_name, client_name)
      key    = key_for(type, movie_name, client_name)
      cached = get_and_parse(key)

      cached ? cached : set(type, movie_name, client_name, yield)
    end

    private

      def get_and_parse(key)
        cached = REDIS.get(key)
        cached ? JSON.parse(cached, symbolize_names: true) : cached
      end

      def key_for(type, movie_name, client_name)
        "movie#{type.to_s}:#{URI.encode(movie_name)}:#{URI.encode(client_name)}"
      end

      def set(type, movie_name, client_name, payload)
        key = key_for(type, movie_name, client_name)
        REDIS.setex(key, TTL, payload.to_json)
        payload
      end
  end
end
