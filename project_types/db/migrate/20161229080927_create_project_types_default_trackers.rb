class CreateProjectTypesDefaultTrackers < ActiveRecord::Migration
  def change
    create_table :project_types_default_trackers do |t|
      t.integer :project_type_id
      t.integer :tracker_id
    end
  end
end
