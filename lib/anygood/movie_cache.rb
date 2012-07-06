module AnyGood
  class MovieCache

    TTL = 14400

    def get(type, movie_name, client_name)
      key = key_for(type, movie_name, client_name)
      get_and_parse(key)
    end

    def write(type, movie_name, client_name, payload)
      key = key_for(type, movie_name, client_name)
      REDIS.setex(key, TTL, payload.to_json)
    end

    private

      def get_and_parse(key)
        cached = REDIS.get(key)
        cached ? JSON.parse(cached, symbolize_names: true) : cached
      end

      def key_for(type, movie_name, client_name)
        "movie#{type.to_s}:#{URI.encode(movie_name)}:#{URI.encode(client_name)}"
      end
  end
end
