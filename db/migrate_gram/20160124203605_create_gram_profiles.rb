class CreateGramProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :birth_last_name
      t.references :account, index: true, foreign_key: true
      t.date :birth_date
      t.date :death_date
      t.string :gender

      t.timestamps null: false
    end
  end
end
