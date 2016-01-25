FactoryGirl.define do
  factory :gram_connection_alias, :class => 'Gram::ConnectionAlias' do
    profile {profile=FactoryGirl.create(:gram_profile, create_without_aliases:true)}
    connection_alias "MyString"
  end

end
