class AddVisibilityToDoorkeeperApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :is_public, :boolean, default: false, null: false
  end
end
