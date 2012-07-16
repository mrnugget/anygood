def rating_with_name(name, ratings)
  ratings.select {|rating| rating['name'] == name}.first
end
