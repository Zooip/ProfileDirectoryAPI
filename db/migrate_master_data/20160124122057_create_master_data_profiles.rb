class CreateMasterDataProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.uuid     :uuid, :unique => true, :index => true
      t.integer :soce_id, :unique => true, :unsigned => true, :index => true
      t.boolean :enable, :default => true
      t.string :encrypted_password, :null => false

      t.string :email, :null => false, :index => true
      t.string :emergency_email, :null => false
      t.string :contact_phone

      t.date :birth_date
      t.date :death_date

      t.string :first_name
      t.string :last_name
      t.string :birth_last_name

      t.string :gender
      
      t.string :login_validation_check
      t.string :description

      t.timestamps null: false
    end

    execute <<-SQL
     CREATE SEQUENCE soce_id_seq START 1000;
     ALTER SEQUENCE soce_id_seq OWNED BY profiles.soce_id;
     ALTER TABLE profiles ALTER COLUMN soce_id SET DEFAULT nextval('soce_id_seq');
     ALTER TABLE profiles ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
    SQL
  end

  def self.down
    drop_table :profiles

    execute <<-SQL
      DROP SEQUENCE soce_id_seq;
    SQL
  end
end
