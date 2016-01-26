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
    profile=FactoryGirl.create(:gram_profile, create_without_aliases:true)
    profile.soce_id=nil
    expect(profile.valid?).to eq(false)
  end

  it "destroy its connection_aliases when destroyes" do |variable|
    profile=FactoryGirl.create(:gram_profile, create_without_aliases:true)
    con_alias=FactoryGirl.create(:gram_connection_alias, profile: profile)
    profile.destroy
    expect(Gram::ConnectionAlias.exists?(con_alias.id)).to eq(false)
  end


  describe "validate that :soce_id is an integer" do
    it "invalidate strings in :soce_id" do
      profile=FactoryGirl.create(:gram_profile, create_without_aliases:true)
      profile.soce_id="string"
      expect(profile.valid?).to eq(false)
    end

    it "invalidate non integer numbers in :soce_id" do
      profile=FactoryGirl.create(:gram_profile, create_without_aliases:true)
      profile.soce_id=157.211
      expect(profile.valid?).to eq(false)
    end
  end


  it "generate can be created without aliases" do
    profile=FactoryGirl.create(:gram_profile, create_without_aliases:true)
    expect(profile.connection_aliases.count).to eq(0)
  end

  describe "sync email and emergency_email" do
    context "when there is not emergency_email" do
      it "update :emergency_email with value of :email" do
        profile=FactoryGirl.create(:gram_profile,email:'roland.vardanega@gadz.org', emergency_email:nil, create_without_aliases:true)
        expect(profile.emergency_email).to eq("roland.vardanega@gadz.org")
      end
    end    
    context "when they are the same before the update" do
      it "update :emergency_email with value of :email" do
        profile=FactoryGirl.create(:gram_profile,email:'roland.vardanega@gadz.org', emergency_email:'roland.vardanega@gadz.org', create_without_aliases:true)
        profile.update_attribute(:email,"roland@gadz.org")
        expect(profile.emergency_email).to eq("roland@gadz.org")
      end
    end
    context "when they are different before the update" do
      it "doesn't change :emergency_email value" do
        profile=FactoryGirl.create(:gram_profile,email:'roland.vardanega@gadz.org', emergency_email:'roland211@hotmail.com', create_without_aliases:true)
        profile.update_attribute(:email,"roland@gadz.org")
        expect(profile.emergency_email).to eq("roland211@hotmail.com")
      end
    end
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
