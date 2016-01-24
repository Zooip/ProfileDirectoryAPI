class CreateGramAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :soce_id, :unique => true
      t.boolean :enable, :default => true
      t.string :encrypted_password, :null => false
      t.string :email, :null => false
      t.date :birthdate
      t.json :name
      t.string :phone
      t.string :login_validation_check
      t.string :description

      t.timestamps null: false
    end
  end
end
