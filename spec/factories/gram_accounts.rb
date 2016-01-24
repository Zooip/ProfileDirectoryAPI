Faker::Config.locale = 'fr'
FactoryGirl.define do
  factory :gram_account, :class => 'Gram::Account' do
    soce_id                 { Faker::Number.between(1000, 500000) }
    enable                  true
    encrypted_password      "no password"
    birthdate               { Faker::Date.between(20.years.ago, 90.years.ago) }
    name                    { "{\"first_name\":\"#{first=Faker::Name.first_name}\",\"last_name\":\"#{last=Faker::Name.last_name}\",\"full_name\":\"#{full=first+" "+last}\"}" }
    email                   { Faker::Internet.safe_email(JSON(name)['full_name']) }
    phone                   { Faker::PhoneNumber.phone_number }
    login_validation_check  {"CGU="+[Faker::Date.between(2.years.ago, Date.today).strftime("%d/%m/%Y"),""].sample}
    description             "Généré via FactoryGirl"
  end

end