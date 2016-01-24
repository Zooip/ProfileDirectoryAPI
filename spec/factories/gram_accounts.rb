FactoryGirl.define do
  factory :gram_account, :class => 'Gram::Account' do
    soce_id 1
    enable false
    encrypted_password "MyString"
    email "MyString"
    birthdate "2016-01-24"
    name ""
    phone "MyString"
    login_validation_check "MyString"
    description "MyString"
  end

end
