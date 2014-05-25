#!/usr/bin/env rake

require File.dirname(__FILE__) + '/config/boot.rb'

unless ENV["RACK_ENV"] == 'production'
  require 'rspec/core/rake_task'

  desc 'Default: run rspec spec'
  task :default => :spec

  desc 'Run rspec specs'
  task :spec do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = './spec/**/*_spec.rb'
    end
  end
end

desc 'Run IRB console with app environment'
task :console do
  puts 'Loading AnyGood bootfile...'
  system('irb -r ./config/boot.rb')
end

namespace :movies do
  desc 'Import movie names from Wikipedia and add to Redis'
  task :import do
    puts "Importing movies of the year #{ENV['year']}"
    movie_matcher  = AnyGood::MovieMatcher.new
    movie_importer = AnyGood::MovieImporter.new(ENV['year'])

    movie_importer.fetch_movies.each do |movie_name|
      movie_matcher.add_movie(name: movie_name, year: ENV['year'])
    end
  end

  desc 'Import movie names from Wikipedia and add to Redis (from the years 2003 - today)'
  task :import_all do
    movie_matcher  = AnyGood::MovieMatcher.new

    (2003..Time.now.year).each do |year|
      puts "Importing movies of the year #{year}"
      movie_importer = AnyGood::MovieImporter.new(year)

      movie_importer.fetch_movies.each do |movie_name|
        movie_matcher.add_movie(name: movie_name, year: year)
      end
    end
  end
end
