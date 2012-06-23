def stub_rottentomatoes_query(movie_name, fixture)
  stub_http_request(
    :get, "http://api.rottentomatoes.com/api/public/v1.0/movies.json?q=#{movie_name}"
  ).with(
    :query => {'apikey' => 'art7wzby22d4vmxfs9zw4qjh'}
  ).to_return(
    body: File.read("./spec/fixtures/#{fixture}.json")
  )
end

def rottentomatoes_api_url
  'http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=art7wzby22d4vmxfs9zw4qjh&q='
end

def stub_imdb_query(movie_name, year, fixture)
  stub_http_request(
    :get, "http://www.imdbapi.com/?t=#{movie_name}"
  ).with(
    :query => { 'y' => year }
  ).to_return(
    body: File.read("./spec/fixtures/#{fixture}.json")
  )
end
