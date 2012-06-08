# Any good?

This is a fun project of mine that in the end should be able to present a user a
lot of different ratings for a given movie, so you don't have to check different
sites in order to know if a movie is any good.

There is still a lot of work to be done, e.g.: the is absolutely no frontend for
this app, the only thing that is kinda working is the API in the background.

## Installation & Usage

Come on, let's get this thing running on your computer:

```bash
git clone git://github.com/mrnugget/anygood.git
cd anygood
bundle install
rackup -p 4567
```

And now open `http://localhost:4567` in your browser.

## Look up a movie's ratings

When you visit the site type in the name of the movie and the year it was
released and the ratings should show up.

## API

The current API resides at `/api/movies`. So, let's say you want to check the
combined ratings for the movie 'Inception' of the year 2010. The API endpoint
would this:

```
/api/movies/2010/Inception
```
The response is JSON and should look like this:

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

## TODO

- Better error handling in the API clients: currently the only thing that is
  working is JSON Parser Errors. Handling of 404, 500, 503 and whatnot should be
  implemented.
- Add the following clients:
  - http://www.themoviedb.org
  - http://www.moviepilot.com
