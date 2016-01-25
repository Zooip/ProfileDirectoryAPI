require 'rails_helper'

RSpec.describe Gram::Profile, type: :model do
  
  it "has a valid factory" do
    expect(FactoryGirl.build(:gram_profile)).to be_valid
  end

  it "has an empty database" do
    expect(Gram::Profile.count).to eq(0)
  end

  it {is_expected.to validate_presence_of :email}
  it {is_expected.to allow_value('roland.vardanega@gadz.org').for(:email)}
  it {is_expected.not_to allow_value('roland.vardanega.gadz.org').for(:email)}
  it {is_expected.to validate_presence_of :encrypted_password}
  it {is_expected.to validate_inclusion_of(:gender).in_array(['male','female'])}
  it "validate presence of :soce_id" do
    account=FactoryGirl.create(:gram_profile, create_without_aliases:true)
    account.soce_id=nil
    expect(account.valid?).to eq(false)
  end

  describe "validate that :soce_id is an integer" do
    it "invalidate strings in :soce_id" do
      account=FactoryGirl.create(:gram_profile, create_without_aliases:true)
      account.soce_id="string"
      expect(account.valid?).to eq(false)
    end

    it "invalidate non integer numbers in :soce_id" do
      account=FactoryGirl.create(:gram_profile, create_without_aliases:true)
      account.soce_id=157.211
      expect(account.valid?).to eq(false)
    end
  end


  it "generate can be created without aliases" do
    account=FactoryGirl.create(:gram_profile, create_without_aliases:true)
    expect(account.connection_aliases.count).to eq(0)
  end

  describe "Soce_id auto_increment" do

    it "auto increment soce_id" do
      account1=FactoryGirl.create(:gram_profile)
      expect(FactoryGirl.create(:gram_profile).soce_id).to eq(account1.soce_id+1)
    end

    describe "update soce_id sequence when user input" do
      context "when user input greater than actual sequence" do
        it "update soce_id next value " do
          account1=FactoryGirl.create(:gram_profile)
          account2=FactoryGirl.create(:gram_profile, soce_id: account1.soce_id+10)
          expect(FactoryGirl.create(:gram_profile).soce_id).to eq(account1.soce_id+11)
        end
      end

      context "when user input lesser than actual sequence" do
        it "doens't update soce_id sequence when user input" do
          account1=FactoryGirl.create(:gram_profile)
          account2=FactoryGirl.create(:gram_profile, soce_id: account1.soce_id+10)
          account3=FactoryGirl.create(:gram_profile, soce_id: account1.soce_id+5)
          expect(FactoryGirl.create(:gram_profile).soce_id).to eq(account1.soce_id+11)
        end
      end
    end
  end
end
