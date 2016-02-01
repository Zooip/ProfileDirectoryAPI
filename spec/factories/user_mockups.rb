FactoryGirl.define do
  factory :user_mockup do
    profile {profile=FactoryGirl.create(:master_data_profile, create_without_aliases:true)}
  end

end
