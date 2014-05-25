# Any good?

[![Build Status](https://secure.travis-ci.org/mrnugget/anygood.png)](http://travis-ci.org/mrnugget/anygood)


So! You quickly want to see if a movie was any good, without sifting through
reviews and comparing different ratings on different websites? Great, AnyGood is
here to help.

Mind you, this is side-project of mine, purely made for fun and interest, there
is no commercial interest involved in this and it's totally open-source. So, go
ahead, if you have any features, ideas, bugfixes, bugs, problems: open a pull
request or submit an issue!

## AnyGood

The application is a pretty small sinatra app with a single html page at the
moment. Caching and autocompletion is handled with Redis.

## API

The base url for the api is `/api`.

### Movies

The basic format of the movie endpoint is

```
/api/movies/<movie_year>/<movie_name>
```

Let's say you want to check the combined ratings for the movie 'Inception' of
the year 2010. The API endpoint would be the following: 

```
/api/movies/2010/Inception
```

This will trigger all the implemented clients to get ratings from their
respective site for the movie. The constructed movie object is then serialized
to JSON and the output from the route above should look like this:

```json
{
  "name": "Inception",
  "info": {
    "poster": "http://content8.flixster.com/movie/10/93/37/10933762_det.jpg",
    "year": 2010
  },
  "ratings": {
    "IMDB": {
      "score": 8.8,
      "url": "http://www.imdb.com/title/tt1375666"
    },
    "Rotten Tomatoes": {
      "score": 8.95,
      "url": "http://www.rottentomatoes.com/m/inception/"
    }
  },
  "combined_rating": 8.875
}
```

### Search & Autocompletion

The autocompletion for the input field is reachable under

```
/api/search
```

In order to get the possible movies you need to supply a `term`:

```
/api/search?term=incep
```

So, with only two movies containing that term in its name, the output would be
the following:

```
{
  "search_term":"Incep",
  "movies":[
    {
      "name":"Inception",
      "year":2010
    },
    {
      "name":"Inception Two - Sweet Dreams",
      "year":2018
    }
  ]
}
```

With that information it's easy to use the `/api/movies` endpoint to get the
ratings for the specified movie.

## Development and Usage
The application needs two environment variables to be set in order to work:

* ROTTEN_TOMATOES_KEY
* THE_MOVIE_DATABASE_KEY

Both need to contain your key for the respective APIs.

## TODO

- Error Handling:

  Handling of 404, 500, 503 and whatnot errors.

- Clients:
  
  There are a couple more clients I'd like to implement:

  - http://www.moviepilot.com

- Movie Info:

  Get more info from RottenTomatoes. Maybe plot description, director
  and main actors.
