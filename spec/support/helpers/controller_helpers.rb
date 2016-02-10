module ControllerHelpers

  RSpec.shared_examples 'a scopable Controller' do
    it "returns a scope directory" do
      expect(subject.class.oauth_scopes_directory.class).to eq(Hash)
    end

    it "add scopes to an actions" do
      Api::V1::ProfilesController.scopes :any_action, 'scope1','scope2'
      expect(subject.class.oauth_scopes_directory[:any_action]).to eq(['scope1','scope2'])
    end

    it "returns action's scopes" do
      Api::V1::ProfilesController.scopes :any_action, 'scope1','scope2'
      expect(subject.send(:scopes_for,:any_action)).to eq(['scope1','scope2'])
    end
  end

  RSpec.shared_examples 'a Oauth protected action' do |http_verb,action,scopes|
    
    let (:action_params) { {format: :json} } 

    context "has no access token" do

      before :each do
        self.send(http_verb, action, action_params)
      end

      it {is_expected.to respond_with :unauthorized }
    end

    scopes ||= ''
    if scopes.present?
      context "has no scopes" do

        let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
        let!(:resource_owner) {resource_owner_profile.create_user_mockup}
        let!(:client_application) { Doorkeeper::Application.create!(:name => "MyApp", :redirect_uri => "https://app.com") }
        let!(:token) { Doorkeeper::AccessToken.create! :application_id => client_application.id, :resource_owner_id => resource_owner.id }

        before :each do
          self.send(http_verb,action,action_params.merge({access_token: token.token}))
        end

        it {is_expected.to respond_with :forbidden }
      end
    end
  end
end