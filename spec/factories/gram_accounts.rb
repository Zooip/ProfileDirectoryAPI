Faker::Config.locale = 'fr'
FactoryGirl.define do
  factory :gram_account, :class => 'Gram::Account' do
    enable                  {[true,false].sample}
    encrypted_password      "no password"
    birthdate               { [Faker::Date.between(20.years.ago, 90.years.ago),nil].sample }
    first_name              { [Faker::Name.first_name,nil].sample}
    last_name               { [Faker::Name.last_name,nil].sample}
    email                   { Faker::Internet.safe_email(first_name.to_s+" "+last_name.to_s+" "+rand(1..10).to_s) }
    phone                   { [Faker::PhoneNumber.phone_number,nil].sample }
    login_validation_check  { ["CGU="+[Faker::Date.between(2.years.ago, Date.today).strftime("%d/%m/%Y"),""].sample,nil].sample}
    description             "Généré via FactoryGirl"
  end

end