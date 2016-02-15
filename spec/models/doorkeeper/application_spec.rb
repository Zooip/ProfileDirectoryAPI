require 'rails_helper'

RSpec.describe Doorkeeper::Application, type: :model do
  it "has a valid factory" do
    expect(FactoryGirl.build(:doorkeeper_application)).to be_valid
  end
end