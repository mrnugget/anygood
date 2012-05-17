require 'spec_helper'

describe AnyGood::Movie do
  it 'has a combined rating' do
    ratings = [8.0, 8.6]

    inception = AnyGood::Movie.new(
      ratings: ratings
    )

    inception.combined_rating.should == 8.3
  end
end
