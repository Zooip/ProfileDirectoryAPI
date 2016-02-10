class CreateMasterDataPhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.references :profile, foreign_key: true, null: false
      t.integer :number
      t.integer :country_code
      t.string :phone_type

      t.timestamps null: false
    end
  end
end
