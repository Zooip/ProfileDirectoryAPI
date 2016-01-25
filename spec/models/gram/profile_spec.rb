require 'rails_helper'

RSpec.describe Gram::Profile, type: :model do
    
  it "has a valid factory" do
    expect(FactoryGirl.build(:gram_profile)).to be_valid
  end

  it "has an empty database" do
    expect(Gram::Profile.count).to eq(0)
  end
end
