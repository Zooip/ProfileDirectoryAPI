FactoryGirl.define do
  factory :master_data_connection_alias, :class => 'MasterData::ConnectionAlias' do
    profile {profile=FactoryGirl.create(:master_data_profile, create_without_aliases:true)}
    connection_alias "MyString"
  end

end
