class CreateUserMockups < ActiveRecord::Migration
  def change
    create_table :user_mockups do |t|

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string    :persistence_token

      t.integer   :profile_id


      # Authlogic::ActsAsAuthentic::PerishableToken
      t.string    :perishable_token

      # Authlogic::Session::MagicColumns
      t.integer   :login_count, default: 0, null: false
      t.integer   :failed_login_count, default: 0, null: false
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip


      t.timestamps null: false
    end
  end
end
