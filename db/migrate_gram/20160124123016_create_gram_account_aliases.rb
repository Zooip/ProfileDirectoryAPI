class CreateGramAccountAliases < ActiveRecord::Migration
  def change
    create_table :account_aliases do |t|
      t.references :account, index: true, foreign_key: true
      t.string :connection_alias, :unique => true

      t.timestamps null: false
    end
  end
end
