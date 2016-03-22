require 'rails_helper'

RSpec.describe "Doorkeeper::ApplicationPolicy" do
  
  subject { Doorkeeper::ApplicationPolicy.new(token, oauth_app) }

  let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, is_public: true) }
  
  let(:resource_owner_profile) {FactoryGirl.create(:master_data_profile)}
  let(:resource_owner) {resource_owner_profile && resource_owner_profile.create_user_mockup}
  let(:client_application) { Doorkeeper::Application.create!(:name => "MyApp", :redirect_uri => "https://app.com") }
  let(:token) { Doorkeeper::AccessToken.create!:application_id => client_application.id, :resource_owner_id => (resource_owner && resource_owner.id), :scopes => scopes }

  let(:all_fields) {[:name, :uid, :secret, :redirect_uri, :scopes, :created_at, :updated_at, :is_public, :owner]}
  let(:public_fields) {[:name, :uid, :redirect_uri, :scopes, :created_at, :updated_at, :is_public, :owner]}

  context "Admin Scope" do
    let(:scopes) { 'scopes.admin' }

    it { is_expected.to permit(:show)    }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:destroy) }

    it "can fetch all fields" do
      expect(subject.fetchable_fields).to match_array(all_fields)
    end
    it "can update all fields" do
      expect(subject.updatable_fields).to match_array(all_fields)
    end

  end

  context "OAuth Manage Scope" do
    let(:scopes) { 'scopes.oauth_apps.manage' }

    it { is_expected.to permit(:show)    }
    it { is_expected.to permit(:create)  }
    it { is_expected.to permit(:update)  }
    it { is_expected.to permit(:destroy) }
    it "can fetch all fields" do
      expect(subject.fetchable_fields).to match_array(all_fields)
    end
    it "can update all fields" do
      expect(subject.updatable_fields).to match_array(all_fields)
    end
  end

  context "scopes.oauth_apps.public.readonly Scope" do
    let(:scopes) { 'scopes.oauth_apps.public.readonly' }

    context "Public App" do
      let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, is_public: true) }
      it { is_expected.to permit(:show)    }
    end
    context "Private App" do
      let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, is_public: false) }
      it { is_expected.not_to permit(:show)    }
    end

    it { is_expected.not_to permit(:create)  }
    it { is_expected.not_to permit(:update)  }
    it { is_expected.not_to permit(:destroy) }
    it "can fetch only public fields" do
      expect(subject.fetchable_fields).to match_array(public_fields)
    end
    it "cannot update any fields" do
      expect(subject.updatable_fields).to match_array([])
    end
  end

  context "scopes.profiles.oauth_apps.readwrite Scope" do
    let(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }

    it "can fetch all fields" do
      expect(subject.fetchable_fields).to match_array(all_fields)
    end
    it "can update all fields" do
      expect(subject.updatable_fields).to match_array(all_fields)
    end

    context "Resource owner is application owner" do
      let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, owner: resource_owner_profile, is_public: false) }

      it { is_expected.to permit(:show)    }
      it { is_expected.to permit(:create)  }
      it { is_expected.to permit(:update)  }
      it { is_expected.to permit(:destroy) }

    end

    context "Resource owner is not application owner" do
      let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, owner: FactoryGirl.create(:master_data_profile), is_public: true) }
      it { is_expected.not_to permit(:show)    }
      it { is_expected.not_to permit(:create)  }
      it { is_expected.not_to permit(:update)  }
      it { is_expected.not_to permit(:destroy) }
    end
  end

    context "scopes.profiles.oauth_apps.readonly Scope" do
    let(:scopes) { 'scopes.profiles.oauth_apps.readonly' }

    it "can fetch only public fields" do
      expect(subject.fetchable_fields).to match_array(public_fields)
    end
    it "cannot update any fields" do
      expect(subject.updatable_fields).to match_array([])
    end

    context "Resource owner is application owner" do
      let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, owner: resource_owner_profile, is_public: false) }

      it { is_expected.to permit(:show)    }
      it { is_expected.not_to permit(:create)  }
      it { is_expected.not_to permit(:update)  }
      it { is_expected.not_to permit(:destroy) }

    end

    context "Resource owner is not application owner" do
      let(:oauth_app) { FactoryGirl.create(:doorkeeper_application, owner: FactoryGirl.create(:master_data_profile), is_public: true) }
      it { is_expected.not_to permit(:show)    }
      it { is_expected.not_to permit(:create)  }
      it { is_expected.not_to permit(:update)  }
      it { is_expected.not_to permit(:destroy) }
    end
  end


  describe "Pundit Scopes" do
    let! (:unowned_public_app) { FactoryGirl.create(:doorkeeper_application, owner: nil, is_public: true) }
    let! (:ressource_owner_owned_private_app) { FactoryGirl.create(:doorkeeper_application, owner: resource_owner_profile, is_public: false) }
    let! (:other_owned_public_app) { FactoryGirl.create(:doorkeeper_application, owner: FactoryGirl.create(:master_data_profile), is_public: true) }
    let(:client_application) {unowned_public_app}

    subject {Pundit.policy_scope(token, Doorkeeper::Application)}

    context "Admin Scope" do
      let(:scopes) { 'scopes.admin' }
      it "Return all applications" do
        is_expected.to match_array([unowned_public_app,ressource_owner_owned_private_app,other_owned_public_app])
      end
    end

    context "Oauth manage Scope" do
      let(:scopes) { 'scopes.oauth_apps.manage' }
      it "returns all applications" do
        is_expected.to match_array([unowned_public_app,ressource_owner_owned_private_app,other_owned_public_app])
      end
    end

    context "scopes.oauth_apps.public.readonly Scope" do
      let(:scopes) { 'scopes.oauth_apps.public.readonly' }
      it "returns public applications" do
        is_expected.to match_array([unowned_public_app,other_owned_public_app])
      end
    end

    context "scopes.profiles.oauth_apps.readonly Scope" do
      let(:scopes) { 'scopes.profiles.oauth_apps.readonly' }
      it "returns applications owned by resource owner" do
        is_expected.to match_array([ressource_owner_owned_private_app])
      end
    end

    context "scopes.profiles.oauth_apps.readwrite Scope" do
      let(:scopes) { 'scopes.profiles.oauth_apps.readwrite' }
      it "returns applications owned by resource owner" do
        is_expected.to match_array([ressource_owner_owned_private_app])
      end
    end

  end

end