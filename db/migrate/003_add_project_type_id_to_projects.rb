class AddProjectTypeIdToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :project_type_id, :integer, null: true
  end
end