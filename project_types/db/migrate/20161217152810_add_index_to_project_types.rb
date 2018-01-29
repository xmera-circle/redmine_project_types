class AddIndexToProjectTypes < ActiveRecord::Migration
  def change
    add_index :project_types, :name, unique: true
  end
end
