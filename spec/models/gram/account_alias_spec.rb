require 'rails_helper'

RSpec.describe Gram::AccountAlias, type: :model do
  it "has a valid factory" do
    expect(FactoryGirl.build(:gram_account_alias)).to be_valid
  end


end
