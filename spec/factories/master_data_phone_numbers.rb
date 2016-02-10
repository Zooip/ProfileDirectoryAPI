FactoryGirl.define do
  factory :master_data_phone_number, class: 'MasterData::PhoneNumber' do
    number 1
    country_code 1
    phone_type "MyString"
  end
end
