class AddPositionColumnToProjectTypes < ActiveRecord::Migration
  def change
    add_column :project_types, :position, :integer
 end
end