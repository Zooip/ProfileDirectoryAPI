module OauthHelpers

  JSONAPI_HEADERS = {
    "ACCEPT" => "application/vnd.api+json",
    "CONTENT_TYPE" => "application/vnd.api+json"
  }
  
  RSpec.shared_context "valid Oauth context", :valid_oauth do
    let!(:scopes) { '' }
    let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
    let!(:resource_owner) {resource_owner_profile && resource_owner_profile.create_user_mockup}
    let!(:client_application) { Doorkeeper::Application.create!(:name => "MyApp", :redirect_uri => "https://app.com") }
    let!(:token) { Doorkeeper::AccessToken.create! :application_id => client_application.id, :resource_owner_id => (resource_owner && resource_owner.id), :scopes => scopes }
  end

  RSpec.shared_examples 'a Oauth protected endpoint' do |http_verb,path, path_params,body,default_headers|

    context "As an unauthentified Application" do

      before :each do
        self.send(http_verb,send(path,path_params),body,default_headers)
      end

      it "ask for authentification" do
        expect(response).to have_http_status(:unauthorized)
      end

      it "return an error" do
        expect(JSON.parse(response.body).keys).to include("errors")
      end
    end

    context "As an authentified Application with no scopes", :valid_oauth do

      let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
      let!(:resource_owner) {resource_owner_profile.create_user_mockup}
      let!(:client_application) { Doorkeeper::Application.create!(:name => "MyApp", :redirect_uri => "https://app.com") }
      let!(:token) { Doorkeeper::AccessToken.create! :application_id => client_application.id, :resource_owner_id => resource_owner.id }

      before :each do
        self.send(http_verb,send(path,path_params),body,default_headers.merge({"Authorization" => "Bearer #{token.token}"}))
      end

      include_examples "invalid scopes error"
    end
  end

  RSpec.shared_examples "invalid scopes error", :invalid_scopes_error do
    it "it respond with 403 Forbidden" do
      expect(response).to have_http_status(:forbidden)
    end
    it "return invalid scopes error" do
      expect(JSON.parse(response.body)["errors"].map{|x| x["title"]}).to include("Invalid Scopes")
    end
  end


  RSpec.shared_examples "not found error", :not_fount_error do
    it "it respond with 404 Not Found" do
      expect(response).to have_http_status(:not_found)
    end

    it "return errors" do
      expect(JSON.parse(response.body).keys).to include("errors")
    end
  end

end
