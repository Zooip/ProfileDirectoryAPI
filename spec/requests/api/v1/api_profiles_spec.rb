require 'rails_helper'

include OauthHelpers

RSpec.describe "Api::V1::Profiles", type: :request do

  describe "GET /api/v1/profiles" do

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_profiles_path,nil ,nil,JSONAPI_HEADERS

    context "As an authentified Application with admin scope", :valid_oauth do
      let (:scopes){'scopes.admin'}

      it "it respond with sucess" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        expect(response).to have_http_status(:success)
      end

      it "it return a list of profiles" do
        get api_v1_profiles_path,nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
        response_data=JSON.parse(response.body)['data']
        expect(response_data.class).to eq(Array)
        response_data.each do |oa|
          expect(oa["type"]).to eq("profiles")
        end
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

    it_behaves_like 'a Oauth protected endpoint', :get, :api_v1_profile_path,100 ,nil,JSONAPI_HEADERS

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

    it_behaves_like 'a Oauth protected endpoint', :post, :api_v1_profiles_path,nil ,nil,JSONAPI_HEADERS

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

  describe "DELETE /api/v1/profiles/:id" do

    let!(:profile) { FactoryGirl.create(:master_data_profile)}

    it_behaves_like 'a Oauth protected endpoint', :delete, :api_v1_profile_path,100 ,nil,JSONAPI_HEADERS

    context "When there is no resource owner", :valid_oauth do
      let!(:resource_owner_profile) {nil}
      context "As an authentified Application with admin scope" do
        let (:scopes){'scopes.admin'}

        it "it respond with sucess" do
          delete api_v1_profile_path(profile), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response).to have_http_status(:no_content)
        end

        it "it return nothing" do
          delete api_v1_profile_path(profile), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response.body).to eq('')
        end

        it "create a delete a profile" do
          expect {
            delete api_v1_profile_path(profile), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          }.to change(MasterData::Profile, :count).by(-1)
        end
      end

      context "As an authentified Application with scopes.profiles.create scope" do
        let (:scopes){'scopes.profiles.delete'}

        it "it respond with sucess" do
          delete api_v1_profile_path(profile), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response).to have_http_status(:no_content)
        end

        it "it return nothing" do
          delete api_v1_profile_path(profile), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          expect(response.body).to eq('')
        end

        it "create a delete a profile" do
          expect {
            delete api_v1_profile_path(profile), nil, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
          }.to change(MasterData::Profile, :count).by(-1)
        end
      end
    end
  end

  describe "PUT /api/v1/profiles/:id" do

    let(:profile_attributes) {{first_name: "Claude", gender: 'male'}}
    let!(:profile) {FactoryGirl.create(:master_data_profile,profile_attributes)}
    let(:profile_data) { FactoryGirl.json_api_attributes_for(:master_data_profile,profile_attributes.merge({first_name: "Paul"})).deep_merge({data:{id:profile.id.to_s}}).to_json }
    let(:invalid_profile_data) { FactoryGirl.json_api_attributes_for(:invalid_master_data_profile, profile_attributes.merge({gender: 'cat'}) ).deep_merge( {data: {id: profile.id.to_s}} ).to_json }

    it_behaves_like 'a Oauth protected endpoint', :put, :api_v1_profile_path,100 ,nil,JSONAPI_HEADERS

    context "When requesting the resource owner's profile", :valid_oauth do
      let!(:resource_owner_profile) {profile}
      context "As an authentified Application with admin scope" do
        let (:scopes){'scopes.admin'}

        context 'with valid data' do
          it "it respond with sucess" do
            put api_v1_profile_path(profile), profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:success)
          end

          it "it return a single Profile record" do
            put api_v1_profile_path(profile), profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
          end

          it "update profile's attributes" do
            put api_v1_profile_path(profile), profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            profile.reload
            expect(profile.first_name).to eq("Paul")
          end
        end

        context 'with invalid data' do
          it "it respond with 422" do
            put api_v1_profile_path(profile), invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "it return errors" do
            put api_v1_profile_path(profile), invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)).to include("errors")
          end

          it "doesn't update profile" do
            put api_v1_profile_path(profile), invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            profile.reload
            expect(profile.gender).to eq("male")
          end
        end
      end

      context "As an authentified Application with scopes.profiles.create scope" do
        let (:scopes){'scopes.profile.basic.readwrite'}

        context 'with valid data' do
          it "it respond with success" do
            put api_v1_profile_path(profile), profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:success)
          end

          it "it return a single Profile record" do
            put api_v1_profile_path(profile), profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)['data']['type']).to eq('profiles')
          end

          it "update profile's attributes" do
            put api_v1_profile_path(profile), profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            profile.reload
            expect(profile.first_name).to eq("Paul")
          end
        end

        context 'with invalid data' do
          it "it respond with 422" do
            put api_v1_profile_path(profile), invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "it return errors" do
            put api_v1_profile_path(profile), invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            expect(JSON.parse(response.body)).to include("errors")
          end

          it "doesn't update profile" do
            put api_v1_profile_path(profile), invalid_profile_data, JSONAPI_HEADERS.merge({"Authorization" => "Bearer #{token.token}"})
            profile.reload
            expect(profile.gender).to eq("male")
          end
        end
      end
    end
  end

end
