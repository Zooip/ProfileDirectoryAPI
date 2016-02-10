require 'rails_helper'

include OauthHelpers

RSpec.describe "Api::V1::Profiles", type: :request do

  JSONAPI_HEADERS = {
    "Accept" => "application/vnd.api+json",
    "Content-Type" => "application/vnd.api+json"
  }




  describe "GET /api/v1/profiles" do
    context "As an unauthentified Application" do
      it "ask for authentification" do
        get api_v1_profiles_path
        expect(response).to have_http_status(:unauthorized)
      end

      it "return an error" do
        get api_v1_profiles_path
        expect(JSON.parse(response.body).keys).to include("errors")
      end
    end

    context "As an authentified Application with no scopes", :valid_oauth do
      it "is forbidden" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "As an authentified Application with admin scope", :valid_oauth do
      let (:scopes){'scopes.admin'}

      it "it respond with sucess" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:success)
      end

      it "it return a list" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(JSON.parse(response.body)['data'].class).to eq(Array)
      end

      it "doesn't expose passwords" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(JSON.parse(response.body)['data'].any? {|x| x['attributes']['password']}).to eq(false)
        expect(JSON.parse(response.body)['data'].any? {|x| x['attributes']['encrypted_password']}).to eq(false)
      end
    end

    context "As an authentified Application with profiles.list", :valid_oauth do
      let (:scopes){'scopes.profiles.list'}
      
      it "it respond with sucess" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:success)
      end

      describe "it display only public attributes" do
        it "display public attributes" do
          get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(JSON.parse(response.body)['data'].all? {|x| (['first_name', 'last_name', 'full_name']-x['attributes'].keys).empty?}).to eq(true)
        end
        it "doesn't display private attributes" do
          get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(JSON.parse(response.body)['data'].all? {|x| (x['attributes'].keys.exclude?('birth_date'))}).to eq(true)
        end
      end
    end
  end

  describe "GET /api/v1/profiles/:id" do

    let!(:profile) { FactoryGirl.create(:master_data_profile) }

    context "As an unauthentified Application" do
      it "ask for authentification" do
        get api_v1_profile_path(profile)
        expect(response).to have_http_status(:unauthorized)
      end

      it "return an error" do
        get api_v1_profile_path(profile)
        expect(JSON.parse(response.body).keys).to include("errors")
      end
    end

    context "As an authentified Application with no scopes", :valid_oauth do
      it "is forbidden" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "As an authentified Application with admin scope", :valid_oauth do
      let (:scopes){'scopes.admin'}

      it "it respond with sucess" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:success)
      end

      it "it return a single Profile record" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
      end

      it "doesn't expose passwords" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(JSON.parse(response.body)['data']['attributes']['password']).to eq(nil)
        expect(JSON.parse(response.body)['data']['attributes']['encrypted_password']).to eq(nil)
      end
    end

    context "As an authentified Application with profiles.list", :valid_oauth do
      let (:scopes){'scopes.profile.public.readonly'}

      it "it respond with sucess" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:success)
      end

      describe "it display only public attributes" do
        it "display public attributes" do
          get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          ['first_name', 'last_name', 'full_name'].each do |attribute|
            expect(JSON.parse(response.body)['data']['attributes'].keys.include?(attribute)).to eq(true)
          end
        end
        it "doesn't display private attributes" do
          get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(JSON.parse(response.body)['data']['attributes'].keys.exclude?('birth_date')).to eq(true)
        end
      end
    end
  end

end
