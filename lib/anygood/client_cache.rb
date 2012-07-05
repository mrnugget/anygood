module AnyGood
  class ClientCache

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
        send("#{type.to_s}_key_for", moviename, clientname)
      end

      def info_key_for(moviename, client_name)
        "movieinfo:#{URI.encode(moviename)}:#{URI.encode(client_name)}"
      end

      def rating_key_for(moviename, client_name)
        "movierating:#{URI.encode(moviename)}:#{URI.encode(client_name)}"
      end

      def set(type, moviename, clientname, payload)
        key = key_for(type, moviename, clientname)
        REDIS.setex(key, TTL, payload.to_json)
        payload
      end
  end
end
