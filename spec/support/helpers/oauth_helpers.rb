module OauthHelpers
  RSpec.shared_context "valid Oauth context", :valid_oauth do
    let!(:scopes) { '' }
    let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
    let!(:resource_owner) {resource_owner_profile && resource_owner_profile.create_user_mockup}
    let!(:client_application) { Doorkeeper::Application.create!(:name => "MyApp", :redirect_uri => "https://app.com") }
    let!(:token) { Doorkeeper::AccessToken.create! :application_id => client_application.id, :resource_owner_id => (resource_owner && resource_owner.id), :scopes => scopes }
  end
end
