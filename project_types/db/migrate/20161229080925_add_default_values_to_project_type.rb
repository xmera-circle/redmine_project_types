class AddDefaultValuesToProjectType < ActiveRecord::Migration
  def change
    add_column :project_types, :is_public, :boolean, :default => false, :null => false
    add_column :project_types, :default_user_role_id, :integer, foreign_key: true
  end
end
