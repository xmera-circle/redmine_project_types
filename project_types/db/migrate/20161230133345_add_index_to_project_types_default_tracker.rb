class AddIndexToProjectTypesDefaultTracker < ActiveRecord::Migration
  def change
    add_index :project_types_default_trackers, :project_type_id
  end
end
