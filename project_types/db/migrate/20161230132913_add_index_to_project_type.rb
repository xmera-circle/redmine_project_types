class AddIndexToProjectType < ActiveRecord::Migration
  def change
    add_index :project_types, :default_user_role_id
  end
end
