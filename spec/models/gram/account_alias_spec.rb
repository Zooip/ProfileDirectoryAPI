require 'rails_helper'

RSpec.describe Gram::AccountAlias, type: :model do
  it "has a valid factory" do
    expect(FactoryGirl.build(:gram_account_alias)).to be_valid
  end

  it "has an empty database" do
    expect(Gram::AccountAlias.count).to eq(0)
  end

  it "generate default aliases for an Account" do
    account=FactoryGirl.create(:gram_account, soce_id: 12045, first_name:"Roland", last_name: "Vardanega", create_without_aliases:true)
    Gram::AccountAlias.create_default_aliases_for account
    expect(account.account_aliases.map{|a| a.connection_alias}).to include("12045")
    expect(account.account_aliases.map{|a| a.connection_alias}).to include("12045Q")
  end

  it {is_expected.to validate_presence_of :connection_alias}
  it {is_expected.to allow_value('roland.vardanega@gadz.org').for(:connection_alias)}
  it {is_expected.to allow_value('12045Q').for(:connection_alias)}
  it {is_expected.not_to allow_value('roland.vardanega gadz.org').for(:connection_alias)}
  it {is_expected.to validate_presence_of :account}

  describe "ActiveRecords validations" do
    subject { FactoryGirl.build(:gram_account_alias) }

    it {is_expected.to belong_to :account}
    it {is_expected.to validate_uniqueness_of :connection_alias}
  end

end
