require 'spec_helper'

describe AnyGood::Movie do
  describe 'initialize' do
    it 'sets the right attributes' do
      ratings = {
        'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
        'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      }

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
      ratings = {
        'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
        'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
      }

      inception = AnyGood::Movie.new(ratings: ratings)

      inception.combined_rating.should == 8.875
    end
  end

  describe '#to_json' do
    it 'returns a representation of the movie as JSON string' do
      movie = AnyGood::Movie.new(
        name: 'Inception',
        year: 2010,
        ratings: {
          'IMDB' => {score: 8.8, url: 'http://www.imdb.com/title/tt1375666/'},
          'Rotten Tomatoes' => {score: 8.95, url: 'http://www.rottentomatoes.com/m/inception/'}
        },
        info: {
          poster: 'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
        }
      )

      parsed_json_movie = JSON.parse(movie.as_json)

      parsed_json_movie['name'].should == 'Inception'
      parsed_json_movie['year'].should == 2010
      parsed_json_movie['ratings']['IMDB']['score'].should == 8.8
      parsed_json_movie['ratings']['Rotten Tomatoes']['score'].should == 8.95
      parsed_json_movie['info']['poster'].should ==  'http://content8.flixster.com/movie/10/93/37/10933762_det.jpg'
    end
  end
end
