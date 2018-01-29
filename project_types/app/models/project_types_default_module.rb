class ProjectTypesDefaultModule < ActiveRecord::Base
  unloadable
  
  belongs_to :project_type
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_type_id
  attr_protected :id
end
