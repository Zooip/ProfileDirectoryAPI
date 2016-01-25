FactoryGirl.define do
  factory :gram_account_alias, :class => 'Gram::AccountAlias' do
    account {account=FactoryGirl.create(:gram_account, create_without_aliases:true)}
    connection_alias "MyString"
  end

end
