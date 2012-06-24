#!/usr/bin/env rake

require File.dirname(__FILE__) + '/config/boot.rb'
require 'rspec/core/rake_task'

desc 'Default: run rspec spec'
task :default => :spec

desc 'Run rspec specs'
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = './spec/**/*_spec.rb'
  end
end

desc 'Run IRB console with app environment'
task :console do
  puts 'Loading AnyGood bootfile...'
  system('irb -r ./config/boot.rb')
end
