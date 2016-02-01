require 'rails_helper'

RSpec.describe UserMockup, type: :model do
  
  describe "Validations" do
    subject { FactoryGirl.build(:user_mockup) }
    it{is_expected.to validate_uniqueness_of(:profile_id)}
    it{is_expected.to validate_presence_of(:profile_id)}
    it {is_expected.to belong_to :profile}
  end

  it 'returns encrypted password of associated Profile' do
    profile= FactoryGirl.create(:master_data_profile, encrypted_password: '3ncrypt3d_p4ss', create_without_aliases:true)
    user_mockup=FactoryGirl.build(:user_mockup, profile: profile)
    expect(user_mockup.encrypted_password).to eq('3ncrypt3d_p4ss')
  end

  describe 'is findable with associated Profile aliases' do
    let!(:profile) {FactoryGirl.create(:master_data_profile, create_without_aliases:true)}
    let!(:p_alias) {profile.connection_aliases.create(connection_alias: 'Toto_du_93')}
    
    context 'existing associated UserMockup' do
      let!(:user_mockup) {FactoryGirl.create(:user_mockup, profile: profile)}

      it 'return an UserMockup' do
        expect(UserMockup.find_by_connection_alias('Toto_du_93')).to eq(user_mockup)
      end

      it 'return an UserMockup associated with defined Profile' do
        finded_um=UserMockup.find_by_connection_alias('Toto_du_93')
        expect(finded_um.profile).to eq(profile)
      end
    end

    context 'no associated UserMockup' do

      it 'create a UserMockup' do
        expect {UserMockup.find_by_connection_alias('Toto_du_93')}.to change(UserMockup,:count).by(1)
      end

      it 'return an UserMockup associated with defined Profile' do
        finded_um=UserMockup.find_by_connection_alias('Toto_du_93')
        expect(finded_um.profile).to eq(profile)
      end
    end
  end

end