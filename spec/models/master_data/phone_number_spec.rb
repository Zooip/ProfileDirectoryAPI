require 'rails_helper'

RSpec.describe MasterData::PhoneNumber, type: :model do
  it "has a valid factory" do
    expect(FactoryGirl.build(:master_data_phone_number)).to be_valid
  end

  it "has an empty database" do
    expect(MasterData::PhoneNumber.count).to eq(0)
  end

  describe "validate that :number is an integer" do
    let (:phone_number) {FactoryGirl.build(:master_data_phone_number)}

    it "invalidate strings in :number" do
      phone_number.number="string"
      expect(phone_number.valid?).to eq(false)
    end

    it "invalidate non integer numbers in :number" do
      phone_number.number=157.211
      expect(phone_number.valid?).to eq(false)
    end
    it "validate integer numbers in :number" do
      phone_number.number=157.211
      expect(phone_number.valid?).to eq(false)
    end
  end

  describe "validate that :country_code is an integer" do
    let (:phone_number) {FactoryGirl.build(:master_data_phone_number)}

    it "invalidate strings in :country_code" do
      phone_number.country_code="string"
      expect(phone_number.valid?).to eq(false)
    end

    it "invalidate non integer numbers in :country_code" do
      phone_number.country_code=157.211
      expect(phone_number.valid?).to eq(false)
    end
    it "validate integer numbers in :country_code" do
      phone_number.country_code=157.211
      expect(phone_number.valid?).to eq(false)
    end
  end

  describe "is formated" do
    let(:phone) {FactoryGirl.build(:master_data_phone_number, number: 123456789, country_code: 33)}

    it "returns an internationnal format" do
      expect(phone.format[:international]).to eq("+33123456789")
    end

    it "returns an readable international format" do
      expect(phone.format[:readable_international]).to eq("+33 123 456 789")
    end

    describe "returns an readable french format if french number" do
      it "returns an readable french format" do
        phone = FactoryGirl.build(:master_data_phone_number, number: 123456789, country_code: 34)
        expect(phone.format[:readable_french]).to eq(nil)
      end

      it "returns an readable french format" do
        expect(phone.format[:readable_french]).to eq("01.23.45.67.89")
      end
    end
  end

  describe "it parse raw phones numbers" do
    let(:phone) {FactoryGirl.build(:master_data_phone_number, number: 123456789, country_code: 1)}

    it "parse international format" do
        phone.parse("+33 (0) 987 654 321")
        expect(phone.number).to eq(987654321)
        expect(phone.country_code).to eq(33)
    end

    it "parse french format" do
        phone.parse("09.87.65.43.21")
        expect(phone.number).to eq(987654321)
        expect(phone.country_code).to eq(33)
    end
  end
end
