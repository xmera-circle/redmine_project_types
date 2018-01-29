class CreateProjectTypesDefaultModules < ActiveRecord::Migration
  def change
    create_table :project_types_default_modules do |t|
      t.integer :project_type_id
      t.string :name, :null => false
    end
    add_index :project_types_default_modules, :project_type_id
    
  end
  
end
