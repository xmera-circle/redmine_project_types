class CreateProjectsProjectTypes < ActiveRecord::Migration
  def change
    create_table :projects_project_types, :id => false do |t|
      t.integer :project_id, :default => 0, :null => false
      t.integer :project_type_id, :default => 0, :null => true
    end
  end

end
