require 'rails_helper'

RSpec.describe MasterData::ProfileSerializer, :type => :serializer do

  context 'Individual Resource Representation' do
    let(:resource) { FactoryGirl.create(:master_data_profile, first_name: 'Jean', last_name: 'Dupont') }

    let(:serializer) { ActiveModel::SerializableResource.new(resource) }
    let(:serialization) { serializer.as_json }

    subject do
      #Parse to use keys as strings and not symbols
      JSON.parse(serialization.to_json)['data']
    end

    it 'has an id that matches #permalink' do
      expect(subject['id']).to eql(resource.id.to_s)
    end

    it 'has a fullname' do
      expect(subject['attributes']['full_name']).to eql("Jean Dupont")
    end
  end
end