class AddIndexToProjectsProjectTypes < ActiveRecord::Migration
  def change    
    add_index :projects_project_types, :project_id, unique: true
    add_index :projects_project_types, :project_type_id
  end
end
