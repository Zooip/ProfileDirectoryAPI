require 'rails_helper'

include OauthHelpers

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

      it "it respond with sucess" do
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

      it "it respond with sucess" do
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

    it_behaves_like 'a Oauth protected endpoint', :post, :api_v1_oauth_applications_path,nil ,nil,JSONAPI_HEADERS

    context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
      context "With valid attributes" do

        let(:valid_unowned_attributes) {
          FactoryGirl.json_api_attributes_for(:doorkeeper_application).to_json
        }

        before :each do
          post api_v1_oauth_applications_path,valid_unowned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        end

        it "it respond with sucess" do
          expect(response).to have_http_status(:success)
        end

        it "create an Application" do
          expect{
            post api_v1_oauth_applications_path,valid_unowned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          }.to change(Doorkeeper::Application, :count).by(1)
        end

        it "return the created application" do
          expect(JSON.parse(response.body)['data'].slice("id","type")).to eq({'type' => "oauth_applications", "id" => Doorkeeper::Application.last.id.to_s})
        end
      end

      context "With invalid attributes" do
        let(:invalid_unowned_attributes) {
          FactoryGirl.json_api_attributes_for(:doorkeeper_application, redirect_uri: "*invalid_uri*").to_json
        }
        before :each do
          post api_v1_oauth_applications_path,invalid_unowned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        end

        it "it respond with 422 Unprocessable Entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "create an Application" do
          expect{
            post api_v1_oauth_applications_path,invalid_unowned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          }.to change(Doorkeeper::Application, :count).by(0)
        end

        it "return errors" do
          expect(JSON.parse(response.body).keys).to include("errors")
        end
      end
    end

    context "When the client has the profiles.oauth_apps.readwrite scope", :valid_oauth do

      let!(:application_owner) {FactoryGirl.create(:master_data_profile, first_name:"Jack")}
      let!(:other_person) {FactoryGirl.create(:master_data_profile, first_name:"Fred")}
      let!(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

      context "Add an application to the current resource owner" do
        let!(:resource_owner_profile) {application_owner}

        context "With valid attributes" do

          let(:valid_owned_attributes) {
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

          before :each do
            post api_v1_oauth_applications_path,valid_owned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          end

          it "it respond with sucess" do
            expect(response).to have_http_status(:success)
          end

          it "create an Application" do
            expect{
              post api_v1_oauth_applications_path,valid_owned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            }.to change(Doorkeeper::Application, :count).by(1)
          end

          it "return the created application" do
            expect(JSON.parse(response.body)['data'].slice("id","type")).to eq({'type' => "oauth_applications", "id" => Doorkeeper::Application.last.id.to_s})
          end
        end

        context "With invalid attributes" do
          let(:invalid_owned_attributes) {
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
          before :each do
            post api_v1_oauth_applications_path,invalid_owned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          end

          it "it respond with 422 Unprocessable Entity" do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "create an Application" do
            expect{
              post api_v1_oauth_applications_path,invalid_owned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            }.to change(Doorkeeper::Application, :count).by(0)
          end

          it "return errors" do
            expect(JSON.parse(response.body).keys).to include("errors")
          end
        end
      end

      context "Add an application an other person" do
        let!(:resource_owner_profile) {application_owner}
        let(:valid_owned_attributes) {
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

        before :each do
          post api_v1_oauth_applications_path,valid_owned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        end

        it "it respond with 403 Forbidden" do
          expect(response).to have_http_status(:forbidden)
        end

        it "doesn't create an Application" do
          expect{
            post api_v1_oauth_applications_path,valid_owned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          }.to change(Doorkeeper::Application, :count).by(0)
        end

        it "return an error" do
          expect(JSON.parse(response.body).keys).to include("errors")
        end
      end

      context "Add an unowned application" do
        let!(:resource_owner_profile) {other_person}
        let(:valid_unowned_attributes) {
          FactoryGirl.json_api_attributes_for(:doorkeeper_application).to_json
        }

        before :each do
          post api_v1_oauth_applications_path,valid_unowned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        end

        it "it respond with 403 Forbidden" do
          expect(response).to have_http_status(:forbidden)
        end

        it "doesn't create an Application" do
          expect{
            post api_v1_oauth_applications_path,valid_unowned_attributes, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          }.to change(Doorkeeper::Application, :count).by(0)
        end

        it "return an error" do
          expect(JSON.parse(response.body).keys).to include("errors")
        end
      end
    end
  end

  describe "GET /api/v1/oauth_applications/:id" do

    let!(:client_app) { Doorkeeper::Application.create!(:name => "Unowned App", :redirect_uri => "https://app.com", is_public: false) }

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_oauth_application_path,100 ,nil,JSONAPI_HEADERS

    describe "Request a private unowned application" do
      let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: nil, is_public: false) }

      context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
        let!(:client_application) {client_app}

        before :each do
          get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
        end

        it "it respond with sucess" do
          expect(response).to have_http_status(:success)
        end

        it "return all oauth_applications" do
          expect(JSON.parse(response.body)['data']['type']).to eq('oauth_applications')
          expect(JSON.parse(response.body)['data']['id']).to eq(oauth_application.id.to_s)
          expect(JSON.parse(response.body)['data']['attributes']['name']).to eq(oauth_application.name)
        end
      end

      context "When the client has the oauth_apps.public.readonly scope", :valid_oauth do
        let!(:client_application) {client_app}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }
        let!(:resource_owner_profile) {nil}

        before :each do
          get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
        end

        it "it respond with Not Found" do
          expect(response).to have_http_status(:not_found)
        end

        it "return errors" do
          expect(JSON.parse(response.body).keys).to include("errors")
        end
      end
    end
    describe "Request a private owned applicationr" do

      let!(:application_owner) {FactoryGirl.create(:master_data_profile)}
      let!(:oauth_application) { Doorkeeper::Application.create!(:name => "My Private App", :redirect_uri => "https://app.com",owner: application_owner, is_public: false) }

      context "When the client has the oauth_apps.manage scope", :manage_oauth_apps do
        let!(:client_application) {client_app}

        before :each do
          get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
        end

        it "it respond with sucess" do
          expect(response).to have_http_status(:success)
        end

        it "return all oauth_applications" do
          expect(JSON.parse(response.body)['data']['type']).to eq('oauth_applications')
          expect(JSON.parse(response.body)['data']['id']).to eq(oauth_application.id.to_s)
          expect(JSON.parse(response.body)['data']['attributes']['name']).to eq(oauth_application.name)
        end
      end

      context "When the client has the scopes.profiles.oauth_apps.readonly scope", :valid_oauth do
        let!(:client_application) {client_app}
        let!(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

        context "When the resource owner is not the application owner" do
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}

          before :each do
            get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
          end

          it "it respond with Not Found" do
            expect(response).to have_http_status(:not_found)
          end

          it "return errors" do
            expect(JSON.parse(response.body).keys).to include("errors")
          end
        end

        context "When the resource owner is the application owner" do
          let!(:resource_owner_profile) {application_owner}

          before :each do
            get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
          end

          it "it respond with sucess" do
            expect(response).to have_http_status(:success)
          end

          it "return all oauth_applications" do
            expect(JSON.parse(response.body)['data']['type']).to eq('oauth_applications')
            expect(JSON.parse(response.body)['data']['id']).to eq(oauth_application.id.to_s)
            expect(JSON.parse(response.body)['data']['attributes']['name']).to eq(oauth_application.name)
          end
        end
      end

      context "When the client has the scopes.oauth_apps.public.readonly scope", :valid_oauth do
        let!(:client_application) {client_app}
        let!(:scopes) { 'scopes.oauth_apps.public.readonly' }

        context "When the resource owner is not the application owner" do
          let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}

          before :each do
            get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
          end

          it "it respond with Not Found" do
            expect(response).to have_http_status(:not_found)
          end

          it "return errors" do
            expect(JSON.parse(response.body).keys).to include("errors")
          end
        end

        context "When the resource owner is the application owner" do
          let!(:resource_owner_profile) {application_owner}

          before :each do
            get api_v1_oauth_application_path(oauth_application.id),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})        
          end

          it "it respond with Not Found" do
            expect(response).to have_http_status(:not_found)
          end

          it "return errors" do
            expect(JSON.parse(response.body).keys).to include("errors")
          end
        end
      end
    end
  end

end