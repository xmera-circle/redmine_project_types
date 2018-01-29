class AddIdentifierColumnToProjectTypes < ActiveRecord::Migration
  def change
    add_column :project_types, :identifier, :boolean
  end
end
