require 'rails_helper'

RSpec.describe "Api::Profiles", type: :request do
  describe "GET /api_profiles" do
    it "works! (now write some real specs)" do
      get api_profiles_path
      expect(response).to have_http_status(200)
    end
  end
end
