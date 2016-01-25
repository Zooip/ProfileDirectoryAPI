Faker::Config.locale = 'fr'
FactoryGirl.define do
  factory :gram_profile, :class => 'Gram::Profile' do
    first_name        {[Faker::Name.first_name,nil].sample}
    last_name         {[Faker::Name.last_name,nil].sample}
    birth_last_name   {[Faker::Name.last_name,nil].sample}
    account           {account=FactoryGirl.create(:gram_account, create_without_aliases:true)}
    birth_date        {[Faker::Date.between(20.years.ago, 90.years.ago),nil].sample}
    death_date        {[Faker::Date.between(40.years.ago, Date.today),nil].sample}
    gender            {["female","male",nil].sample}
  end
end
