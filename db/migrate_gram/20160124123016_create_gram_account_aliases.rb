class CreateGramAccountAliases < ActiveRecord::Migration
  def change
    create_table :connection_aliases do |t|
      t.references :profile, foreign_key: true, null: false
      t.string :connection_alias, :unique => true

      t.timestamps null: false
    end

    add_index :connection_aliases, :profile_id
  end
end
