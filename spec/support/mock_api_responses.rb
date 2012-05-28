def mock_response_for(client, response_fixture)
  client.class_eval do
    private
    define_method(:query_api) do
      File.read('./spec/fixtures/' + response_fixture)
    end
  end
end
