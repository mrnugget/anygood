module AnyGood
  class MovieCache

    TTL = 14400

    def get(type, moviename, clientname)
      key    = key_for(type, moviename, clientname)
      cached = get_and_parse(key)

      cached ? cached : set(type, moviename, clientname, yield)
    end

    private

      def get_and_parse(key)
        cached = REDIS.get(key)
        cached ? JSON.parse(cached, symbolize_names: true) : cached
      end

      def key_for(type, moviename, clientname)
        "movie#{type.to_s}:#{URI.encode(moviename)}:#{URI.encode(clientname)}"
      end

      def set(type, moviename, clientname, payload)
        key = key_for(type, moviename, clientname)
        REDIS.setex(key, TTL, payload.to_json)
        payload
      end
  end
end
