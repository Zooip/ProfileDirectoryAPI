FactoryGirl.define do
  factory :gram_account_alias, :class => 'Gram::AccountAlias' do
    account nil
    connection_alias "MyString"
  end

end
