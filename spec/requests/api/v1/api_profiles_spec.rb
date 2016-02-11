require 'rails_helper'

include OauthHelpers

RSpec.describe "Api::V1::Profiles", type: :request do

  JSONAPI_HEADERS = {
    "ACCEPT" => "application/vnd.api+json",
    "CONTENT_TYPE" => "application/vnd.api+json"
  }

  describe "GET /api/v1/profiles" do
    context "As an unauthentified Application" do
      it "ask for authentification" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS
        expect(response).to have_http_status(:unauthorized)
      end

      it "return an error" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS
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
      let (:scopes){'scopes.profiles.list.readonly'}

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
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS
        expect(response).to have_http_status(:unauthorized)
      end

      it "return an error" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS
        expect(JSON.parse(response.body).keys).to include("errors")
      end
    end

    context "As an authentified Application with no scopes", :valid_oauth do
      it "is forbidden" do
        get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "When requesting the resource owner's profile", :valid_oauth do
      let!(:resource_owner_profile) {profile}
      context "As an authentified Application with admin scope" do
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

      context "As an authentified Application with profile.public.readonly", :valid_oauth do
        let (:scopes){'scopes.profile.public.readonly'}

        it "it respond with sucess" do
          get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response).to have_http_status(:success)
        end

        describe "it display only public attributes" do
          it "display public attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            ['first_name', 'last_name', 'full_name'].each do |attribute|
              expect(JSON.parse(response.body)['data']['attributes']).to include(attribute)
            end
          end
          it "doesn't display private attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['attributes']).not_to include('birth_date')
          end
        end
      end

      context "As an authentified Application with profiles.phones", :valid_oauth do
        let (:scopes){'scopes.profile.public.readonly scopes.profile.phones.readonly'}
        let!(:phone) { FactoryGirl.create(:master_data_phone_number, profile_id: resource_owner_profile.id) }

        it "it respond with sucess" do
          get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response).to have_http_status(:success)
        end

        describe "it display only public attributes" do
          it "display public attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            ['first_name', 'last_name', 'full_name'].each do |attribute|
              expect(JSON.parse(response.body)['data']['attributes']).to include(attribute)
            end
          end
          it "display phone relations" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['relationships']).to include('phone_numbers')
          end
          it "doesn't display private attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['attributes']).not_to include('birth_date')
          end
        end
      end
    end

    context "When requesting an other profile than resource owner's profile", :valid_oauth do
      let!(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
      context "As an authentified Application with admin scope" do
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

      context "As an authentified Application with profile.public.readonly", :valid_oauth do
        let (:scopes){'scopes.profile.public.readonly'}

        it "it respond with sucess" do
          get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response).to have_http_status(:success)
        end

        describe "it display only public attributes" do
          it "display public attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            ['first_name', 'last_name', 'full_name'].each do |attribute|
              expect(JSON.parse(response.body)['data']['attributes']).to include(attribute)
            end
          end
          it "doesn't display private attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['attributes']).not_to include('birth_date')
          end
        end
      end

      context "As an authentified Application with profiles.phones", :valid_oauth do
        let (:scopes){'scopes.profile.public.readonly scopes.profile.phones.readonly'}
        let!(:phone) { FactoryGirl.create(:master_data_phone_number, profile_id: resource_owner_profile.id) }

        it "it respond with sucess" do
          get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response).to have_http_status(:success)
        end

        describe "it display only public attributes" do
          it "display public attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            ['first_name', 'last_name', 'full_name'].each do |attribute|
              expect(JSON.parse(response.body)['data']['attributes']).to include(attribute)
            end
          end
          it "doesn't display phone relations" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['relationships'].to_h).not_to include('phone_numbers')
          end
          it "doesn't display private attributes" do
            get api_v1_profile_path(profile),nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['attributes']).not_to include('birth_date')
          end
        end
      end
    end
  end


  describe "POST /api/v1/profiles" do

    let(:profile_data) { FactoryGirl.json_api_attributes_for(:master_data_profile).to_json }
    let(:invalid_profile_data) { FactoryGirl.json_api_attributes_for(:invalid_master_data_profile).to_json }


    context "As an unauthentified Application" do
      it "ask for authentification" do
        post api_v1_profiles_path, profile_data, JSONAPI_HEADERS
        expect(response).to have_http_status(:unauthorized)
      end

      it "return an error" do
        post api_v1_profiles_path, profile_data, JSONAPI_HEADERS
        expect(JSON.parse(response.body)).to include("errors")
      end
    end

    context "As an authentified Application with no scopes", :valid_oauth do
      it "is forbidden" do
        post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "When there is no resource owner", :valid_oauth do
      let!(:resource_owner_profile) {nil}
      context "As an authentified Application with admin scope" do
        let (:scopes){'scopes.admin'}

        context 'with valid data' do
          it "it respond with sucess" do
            post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:success)
          end

          it "it return a single Profile record" do
            post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
          end

          it "create a new profile" do
            expect {
              post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            }.to change(MasterData::Profile, :count).by(1)
          end
        end

        context 'with invalid data' do
          it "it respond with 422" do
            post api_v1_profiles_path, invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "it return errors" do
            post api_v1_profiles_path, invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)).to include("errors")
          end

          it "doesn't create a new profile" do
            expect {
              post api_v1_profiles_path, invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            }.to change(MasterData::Profile, :count).by(0)
          end
        end
      end

      context "As an authentified Application with scopes.profiles.create scope" do
        let (:scopes){'scopes.profiles.create'}

        context 'with valid data' do
          it "it respond with success" do
            post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:success)
          end

          it "it return a single Profile record" do
            post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
          end

          it "create a new profile" do
            expect {
              post api_v1_profiles_path, profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            }.to change(MasterData::Profile, :count).by(1)
          end
        end

        context 'with invalid data' do
          it "it respond with 422" do
            post api_v1_profiles_path, invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "it return errors" do
            post api_v1_profiles_path, invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)).to include("errors")
          end

          it "doesn't create a new profile" do
            expect {
              post api_v1_profiles_path, invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            }.to change(MasterData::Profile, :count).by(0)
          end
        end
      end
    end
  end

end
