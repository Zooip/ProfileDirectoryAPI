class CreateGramAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :soce_id, :unique => true, :unsigned => true
      t.boolean :enable, :default => true
      t.string :encrypted_password, :null => false
      t.string :email, :null => false
      t.date :birthdate
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :login_validation_check
      t.string :description

      t.timestamps null: false
    end
    add_index :accounts, :soce_id, unique: true
    add_index :accounts, :email

    execute <<-SQL
     CREATE SEQUENCE soce_id_seq START 1000;
     ALTER SEQUENCE soce_id_seq OWNED BY accounts.soce_id;
     ALTER TABLE accounts ALTER COLUMN soce_id SET DEFAULT nextval('soce_id_seq');
    SQL
  end

  def self.down
    drop_table :accounts

    execute <<-SQL
      DROP SEQUENCE soce_id_seq;
    SQL
  end
end
