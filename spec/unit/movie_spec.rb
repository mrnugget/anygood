require 'spec_helper'

describe AnyGood::Movie do
  describe 'initialize' do
    it 'sets the right attributes' do
      ratings = [
        {name: 'IMDB', score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
        {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      ]

      movie = AnyGood::Movie.new(
        name: 'Inception',
        year: 2010,
        ratings: ratings,
        info: 'movie_info_string'
      )

      movie.name.should == 'Inception'
      movie.year.should eq(2010)
      movie.ratings.should == ratings
      movie.info.should == 'movie_info_string'
    end
  end

  describe '#combined_rating' do
    it 'returns the calculated combined rating' do
      ratings = [
        {name: 'IMDB', score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
        {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      ]

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 8.875
    end

    it 'ignores ratings with errors' do
      ratings = [
        {name: 'IMDB', error: 'Could not be loaded'},
        {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      ]

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 8.95
    end

    it 'returns 0 when all ratings have errors' do
      ratings = [
        {name: 'IMDB', error: 'Could not be loaded'},
        {name: 'Rotten Tomatoes', error: 'Could not be loaded'}
      ]

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 0
    end

    it 'ignores ratings that are nil' do
      ratings = [
        {name: 'IMDB', score: nil},
        {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      ]

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 8.95
    end

    it 'ignores ratings that are zero' do
      ratings = [
        {name: 'IMDB', score: 0},
        {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      ]

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 8.95
    end

    it 'handles ratings without score' do
      ratings = [
        {name: 'IMDB'},
        {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      ]

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 8.95
    end
  end

  describe '#to_json' do
    it 'returns a representation of the movie as JSON string' do
      movie = AnyGood::Movie.new(
        name: 'Inception',
        year: 2010,
        ratings: [
          {name: 'IMDB', score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
          {name: 'Rotten Tomatoes', score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
        ],
        info: {
          poster: 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
        }
      )

      parsed_json_movie = JSON.parse(movie.as_json)

      parsed_json_movie['name'].should == 'Inception'
      parsed_json_movie['year'].should == 2010
      parsed_json_movie['ratings'].first['score'].should == 8.8
      parsed_json_movie['ratings'].last['score'].should == 8.95
      parsed_json_movie['info']['poster'].should ==  'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
    end
  end
end
