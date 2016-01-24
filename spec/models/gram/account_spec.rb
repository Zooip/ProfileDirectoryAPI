require 'rails_helper'

RSpec.describe Gram::Account, type: :model do
  
  it "has a valid factory" do
    expect(FactoryGirl.build(:gram_account)).to be_valid
  end

  it "create accounts" do
    FactoryGirl.create(:gram_account)
    expect(Gram::Account.count).to eq(1)
  end


end
