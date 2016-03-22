require 'rails_helper'

include OauthHelpers
include ProfilesHelpers

RSpec.describe "Api::V1::OAuthApplications", type: :request do

  RSpec.shared_context "oauth_apps.manage scope", :manage_oauth_apps do
    include_context "valid Oauth context"
    let!(:scopes) { 'scopes.oauth_apps.manage' }
    let!(:resource_owner_profile) {nil}
  end

  describe "GET /api/v1/oauth_applications" do

    let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
    let!(:unowned_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }
    let!(:private_app) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false) }
    let!(:public_app) { Doorkeeper::Application.create!(:name => "My Public App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true) }

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_oauth_applications_path,nil ,nil,JSONAPI_HEADERS

    context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
      let!(:client_application) {unowned_app}

      before :each do
        get api_v1_oauth_applications_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end

      it "return all oauth_applications" do
        expected_array=[unowned_app,private_app,public_app]
        to_eq_arr=expected_array.map{|x| {"type" => "oauth_applications", "id" => x.id.to_s}}
        expect(JSON.parse(response.body)['data'].map{|x| x.slice("id","type")}).to match_array(to_eq_arr)
      end
    end

    context "When the client has the oauth_apps.public.readonly scope", :valid_oauth do
      let!(:client_application) {unowned_app}
      let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
      let!(:resource_owner_profile) {nil}

      before :each do
        get api_v1_oauth_applications_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end

      it "return only public oauth_applications" do
        expected_array=[public_app]
        to_eq_arr=expected_array.map{|x| {"type" => "oauth_applications", "id" => x.id.to_s}}
        expect(JSON.parse(response.body)['data'].map{|x| x.slice("id","type")}).to match_array(to_eq_arr)
      end
    end
  end

  describe "POST /api/v1/oauth_applications" do

    RSpec.shared_examples "successfully created" do
      let(:action) {post api_v1_oauth_applications_path,valid_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})}

      it "it respond with 200 Success" do
        action
        expect(response).to have_http_status(:success)
      end

      it "create an Application" do
        expect{action}.to change(Doorkeeper::Application, :count).by(1)
      end

      it "return the created application" do
        action
        expect(JSON.parse(response.body)['data'].slice("id","type")).to eq({'type' => "oauth_applications", "id" => Doorkeeper::Application.last.id.to_s})
      end
    end

    RSpec.shared_examples "unprocessable entity error" do
      let(:action) {post api_v1_oauth_applications_path,invalid_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})}

      it "it respond with 422 Unprocessable Entity" do
        action
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "doesn't create an Application" do
        expect{action}.to change(Doorkeeper::Application, :count).by(0)
      end

      it "return errors" do
        action
        expect(JSON.parse(response.body).keys).to include("errors")
      end
    end

    RSpec.shared_examples "forbidden error" do
      let(:action) {post api_v1_oauth_applications_path,valid_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})}

      it "it respond with 403 Forbidden" do
        action
        expect(response).to have_http_status(:forbidden)
      end

      it "doesn't create an Application" do
        expect{action}.to change(Doorkeeper::Application, :count).by(0)
      end

      it "return an error" do
        action
        expect(JSON.parse(response.body).keys).to include("errors")
      end
    end

    it_behaves_like 'a Oauth protected endpoint', :post, :api_v1_oauth_applications_path,nil ,nil,JSONAPI_HEADERS

    context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
      context "With valid attributes" do

        let(:valid_attributes) {
          FactoryGirl.json_api_attributes_for(:doorkeeper_application).to_json
        }
        include_examples "successfully created"
      end

      context "With invalid attributes" do
        let(:invalid_attributes) {
          FactoryGirl.json_api_attributes_for(:doorkeeper_application, redirect_uri: "*invalid_uri*").to_json
        }
        include_examples "unprocessable entity error"
      end
    end

    context "When the client has the profiles.oauth_apps.readwrite scope", :valid_oauth do

      let!(:application_owner) {FactoryGirl.create(:master_data_profile, first_name:"Jack")}
      let!(:other_person) {FactoryGirl.create(:master_data_profile, first_name:"Fred")}
      let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

      context "Add an application to the current resource owner" do
        let!(:resource_owner_profile) {application_owner}

        context "With valid attributes" do

          let(:valid_attributes) {
            #FactoryGirl.json_api_attributes_for(:doorkeeper_application, owner: application_owner).to_json
            {"data":
                {
                    "type":"oauth_applications",
                    "attributes":{
                        "name":"My Awesome App !",
                        "redirect_uri":"https://myawesomeapp.com/oauth/redirect",
                        "scopes":""
                        
                    },
                    "relationships": {
                      "owner": {
                         "data": {
                            "type": "profiles",
                            "id": "#{application_owner.id}"
                          }
                      }
                    }
                }
            }.to_json
          }
          include_examples "successfully created"
        end

        context "With invalid attributes" do
          let(:invalid_attributes) {
            #FactoryGirl.json_api_attributes_for(:doorkeeper_application, redirect_uri: "*invalid_uri*", owner: application_owner).to_json
            {"data":
                {
                    "type":"oauth_applications",
                    "attributes":{
                        "name":"My Awesome App !",
                        "redirect_uri":"*invalid_uri*",
                        "scopes":""
                        
                    },
                    "relationships": {
                      "owner": {
                         "data": {
                            "type": "profiles",
                            "id": "#{application_owner.id}"
                          }
                      }
                    }
                }
            }.to_json
          }
          include_examples "unprocessable entity error"
        end
      end

      context "Add an application an other person" do
        let!(:resource_owner_profile) {application_owner}
        let(:valid_attributes) {
          #FactoryGirl.json_api_attributes_for(:doorkeeper_application, owner: other_person).to_json
          {"data":
              {
                  "type":"oauth_applications",
                  "attributes":{
                      "name":"My Awesome App !",
                      "redirect_uri":"https://myawesomeapp.com/oauth/redirect",
                      "scopes":""
                      
                  },
                  "relationships": {
                    "owner": {
                       "data": {
                          "type": "profiles",
                          "id": "#{other_person.id}"
                        }
                    }
                  }
              }
          }.to_json
        }
        include_examples "forbidden error"        
      end

      context "Add an unowned application" do
        let!(:resource_owner_profile) {other_person}
        let(:valid_attributes) {
          FactoryGirl.json_api_attributes_for(:doorkeeper_application).to_json
        }
        include_examples "forbidden error" 
      end
    end
  end

  describe "GET /api/v1/oauth_applications/:id" do

    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    RSpec.shared_examples "successfully displayed" do
      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end

      it "return requested oauth_applications" do
        expect(JSON.parse(response.body)['data']['type']).to eq('oauth_applications')
        expect(JSON.parse(response.body)['data']['id']).to eq(oauth_application.id.to_s)
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq(oauth_application.name)
      end
    end

    RSpec.shared_examples "successfully displayed with private data" do
      include_examples "successfully displayed"
      it "displays private attributes" do
          expect(JSON.parse(response.body)['data']['attributes']['secret']).to eq("1234")
      end
    end

    RSpec.shared_examples "successfully displayed without private data" do
      include_examples "successfully displayed"
      it "doesn't display private attributes" do
          expect(JSON.parse(response.body)['data']['attributes']['secret']).to eq(nil)
      end
    end

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_oauth_application_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do
      before :each do
        get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end
      describe "Request a private unowned application" do
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "successfully displayed with private data"
        end

        context "When the client has the oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
          let!(:resource_owner_profile) {nil}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end
      end

      describe "Request a private owned applicationr" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "successfully displayed with private data"
        end

        context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
          let!(:resource_owner_profile) {application_owner}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully displayed with private data"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully displayed without private data"
          end
        end
      end

      describe "Request a public owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "successfully displayed with private data"
        end

        context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "successfully displayed without private data"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully displayed without private data"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully displayed without private data"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully displayed with private data"
          end
        end
      end
    end
  end

  describe "DELETE /api/v1/oauth_applications/:id" do

    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    it_behaves_like 'a Oauth protected endpoint', :delete, :api_v1_oauth_application_path,100 ,nil,JSONAPI_HEADERS
 
    RSpec.shared_examples "successfully deleted" do
      it "it respond with 204 No Content" do
        expect(response).to have_http_status(:no_content)
      end

      it "return no content" do
        expect(response.body).to eq('')
      end

      it "delete the application" do
        expect{oauth_application.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with valid oauth" do
      before :each do
        delete api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow oauth_apps.public.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Delete a private unowned application" do
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "successfully deleted"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end
      end


      describe "Delete a private owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "successfully deleted"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully deleted"
          end
        end
      end

      describe "Delete a public owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Public App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "successfully deleted"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "successfully deleted"
          end
        end
      end
    end
  end

  describe "PUT /api/v1/oauth_applications/:id" do
    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    RSpec.shared_examples "processable update" do
      context "With valid attributes" do
        let(:body) {valid_attributes}

        it "it respond with 200 Success" do
          expect(response).to have_http_status(:success)
        end 

        it "return requested oauth_application" do
          expect(JSON.parse(response.body)['data']['id']).to eq(oauth_application.id.to_s)
        end

        it "update requested oauth_application" do
          expect(JSON.parse(response.body)['data']['attributes']['redirect_uri']).to eq("https://newuri.com")
        end
      end

      context "With invalid attributes" do
        let(:body) {invalid_attributes}

        it "it respond with 422 Unprocessable Entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "doesn't update requested oauth_application" do
          oauth_application.reload
          expect(oauth_application.redirect_uri).to eq("https://app.com")
        end

        it "return errors" do
          expect(JSON.parse(response.body).keys).to include("errors")
        end
      end
    end

    let(:valid_attributes){
      {"data":
          {
              "type":"oauth_applications",
              "id": "#{oauth_application.id}",
              "attributes":{
                  "redirect_uri": "https://newuri.com"                        
              },
          }
      }.to_json}

    let(:invalid_attributes){
      {"data":
          {
              "type":"oauth_applications",
              "id": "#{oauth_application.id}",
              "attributes":{
                  "redirect_uri": "***invalid_uri***"                        
              },
          }
      }.to_json}

    it_behaves_like 'a Oauth protected endpoint', :put, :api_v1_oauth_application_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do
      let(:body) {nil}
      before :each do
        put api_v1_oauth_application_path(oauth_application.id), body, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
        before :each do
          put api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
        end
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow oauth_apps.public.readonly scope", :valid_oauth do
        before :each do
          put api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
        end
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Update a private unowned application" do
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}        
          include_examples "processable update"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          let(:body) {valid_attributes}
          include_examples "not found error"
        end
      end

      describe "Update a private owned application" do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}        
          include_examples "processable update"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            let(:body) {valid_attributes}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "processable update"
          end
        end
      end

      describe "Update a public owned application" do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Public App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}        
          include_examples "processable update"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            let(:body) {valid_attributes}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "processable update"
          end
        end
      end
    end
  end

  describe "POST /api/v1/oauth_applications/:id/reset_secret" do
   let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    RSpec.shared_examples "success update secret" do
      it "it respond with 302 Redirect" do
        expect(response).to have_http_status(:redirect)
      end 

      it "redirect to requested oauth_application" do
        expect(response.headers["Location"]).to eq(api_v1_oauth_application_url(oauth_application.id))
      end

      it "change oauth_application secret" do
        oauth_application.reload
        expect(oauth_application.secret).not_to eq("1234")
      end
    end

    it_behaves_like 'a Oauth protected endpoint', :post, :reset_secret_api_v1_oauth_application_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do
      before :each do
        post reset_secret_api_v1_oauth_application_path(oauth_application.id), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow oauth_apps.public.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Update secret of a private unowned application" do
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false, secret: 1234) }
        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "success update secret"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
          include_examples "not found error"
          it "doesn't change oauth_application secret" do
            oauth_application.reload
            expect(oauth_application.secret).to eq("1234")
          end
        end
      end

      describe "Update secret of a private owned application" do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}        

          include_examples "success update secret"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
            it "doesn't change oauth_application secret" do
              oauth_application.reload
              expect(oauth_application.secret).to eq("1234")
            end
            
          end
          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "success update secret"
          end
        end
      end

      describe "Update secret of a public owned application" do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Public App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}        
          include_examples "success update secret"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
            it "doesn't change oauth_application secret" do
              oauth_application.reload
              expect(oauth_application.secret).to eq("1234")
            end
          end
          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "success update secret"
          end
        end
      end
    end
  end

  describe "GET /api/v1/oauth_applications/:id/owner" do
    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    RSpec.shared_examples "returns owner with success and have one" do
      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end 

      it "it return a single Profile record" do
        expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
      end

      it "it return requested Profile record" do
        expect(JSON.parse(response.body)['data']['id']).to eq(application_owner.id.to_s)
      end

      it "contain public infos" do
        profiles_public_attributes.each do |attribute|
          expect(JSON.parse(response.body)['data']['attributes']).to include(attribute)
        end
      end
    end

    RSpec.shared_examples "returns owner with success and have none" do
      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end 

      it "it return an empty data" do
        expect(JSON.parse(response.body)).to have_key('data')
        expect(JSON.parse(response.body)['data']).to eq(nil)
      end
    end

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_oauth_application_owner_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do
      let(:body) {nil}
      before :each do
        get api_v1_oauth_application_owner_path(oauth_application.id), body, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Request a private unowned application" do
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "returns owner with success and have none"
        end

        context "When the client has the oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
          let!(:resource_owner_profile) {nil}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end
      end


      describe "Request a private owned applicationr" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "returns owner with success and have one"
        end

        context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly scopes.profile.public.readonly' }
          let!(:resource_owner_profile) {application_owner}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "returns owner with success and have one"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "returns owner with success and have one"
          end
        end
      end


      describe "Request a public owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "returns owner with success and have one"
        end

        context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "returns owner with success and have one"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "returns owner with success and have one"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "returns owner with success and have one"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "returns owner with success and have one"
          end
        end
      end

    end
  end

  describe "GET /api/v1/oauth_applications/:id/relationships/owner" do
    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    RSpec.shared_examples "return owner relationship with success and have one" do
      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end 

      it "it return a single Profile record" do
        expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
      end

      it "it return requested Profile record" do
        expect(JSON.parse(response.body)['data']['id']).to eq(application_owner.id.to_s)
      end
    end

    RSpec.shared_examples "return owner relationship with success and have none" do
      it "it respond with 200 Success" do
        expect(response).to have_http_status(:success)
      end 

      it "it return an empty data" do
        expect(JSON.parse(response.body)).to have_key('data')
        expect(JSON.parse(response.body)['data']).to eq(nil)
      end
    end

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_oauth_application_relationships_owner_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do
      let(:body) {nil}
      before :each do
        get api_v1_oauth_application_relationships_owner_path(oauth_application.id), body, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Request a private unowned application" do
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "return owner relationship with success and have none"
        end

        context "When the client has the oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
          let!(:resource_owner_profile) {nil}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
          include_examples "not found error"
        end
      end


      describe "Request a private owned applicationr" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "return owner relationship with success and have one"
        end

        context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly scopes.profile.public.readonly' }
          let!(:resource_owner_profile) {application_owner}
          include_examples "not found error"
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "return owner relationship with success and have one"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "return owner relationship with success and have one"
          end
        end
      end


      describe "Request a public owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          include_examples "return owner relationship with success and have one"
        end

        context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.oauth_apps.public.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "return owner relationship with success and have one"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "return owner relationship with success and have one"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "return owner relationship with success and have one"
          end
        end

        context "When the client has the scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
          let!(:client_application) {client_app}
          let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

          context "When the resource owner is not the application owner" do
            let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
            include_examples "not found error"
          end

          context "When the resource owner is the application owner" do
            let!(:resource_owner_profile) {application_owner}
            include_examples "return owner relationship with success and have one"
          end
        end
      end

    end
  end

  describe "PUT /api/v1/oauth_applications/:id/relationships/owner" do
    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }


    it_behaves_like 'a Oauth protected endpoint', :put, :api_v1_oauth_application_relationships_owner_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do
      
      let (:other_application_owner) {FactoryGirl.create(:master_data_profile)}
      let (:non_existing_id) {MasterData::Profile.last.id+1}

      let (:transfer_to_other_guy_body) {
        {
          "data": {
            "type": "profiles",
            "id": other_application_owner.id.to_s
          }
        }.to_json
      }

      let (:remove_ownership_body) {
        {
          "data": nil
        }.to_json
      }

      let (:transfer_to_non_existing_guy_body) {
        {
          "data": {
            "type": "profiles",
            "id": non_existing_id
          }
        }.to_json
      }


      let(:body) {nil}
      before :each do
        put api_v1_oauth_application_relationships_owner_path(oauth_application.id), body, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow oauth_apps.public.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Request a public owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}
          
          describe "tranfer ownership to an other person" do
            context "the other person exists" do
              let(:body) {transfer_to_other_guy_body}

              it "respond with 200 Success" do
                expect(response).to have_http_status(:success)
              end 

              it "transfer ownership" do
                oauth_application.reload
                expect(oauth_application.owner).to eq(other_application_owner)
              end
            end
            
            context "the other person doesn't exist" do
              let(:body) {transfer_to_non_existing_guy_body}

              it "respond with 422 Unprocessable Entity" do
                expect(response).to have_http_status(:unprocessable_entity)
              end

              it "doesn't transfer ownership" do
                oauth_application.reload
                expect(oauth_application.owner).to eq(application_owner)
              end
            end
          end

          describe "remove ownership" do
            let(:body) {remove_ownership_body}

            it "respond with 200 Success" do
                expect(response).to have_http_status(:success)
              end 

            it "remove ownership" do
              oauth_application.reload
              expect(oauth_application.owner).to eq(nil)
            end
          end
        end
      end
    end
  end

  describe "DELETE /api/v1/oauth_applications/:id/relationships/owner" do
    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }


    it_behaves_like 'a Oauth protected endpoint', :delete, :api_v1_oauth_application_relationships_owner_path,100 ,nil,JSONAPI_HEADERS

    context "with valid oauth" do

      let(:body) {nil}
      before :each do
        delete api_v1_oauth_application_relationships_owner_path(oauth_application.id), body, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readwrite scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Doesn't allow oauth_apps.public.readonly scope", :valid_oauth do
        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }
        let!(:client_application) {client_app}
        let!(:resource_owner_profile) {application_owner}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
        include_examples "invalid scopes error"
      end

      describe "Request a public owned application" do

        let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
        let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: true, secret: 1234) }

        context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
          let!(:client_application) {client_app}

          describe "remove ownership" do

            it "respond with 200 Success" do
                expect(response).to have_http_status(:success)
              end 

            it "remove ownership" do
              oauth_application.reload
              expect(oauth_application.owner).to eq(nil)
            end
          end
        end
      end
    end
  end

end