class ProjectTypesDefaultTracker < ActiveRecord::Base
  unloadable
  
  belongs_to :project_type
  belongs_to :tracker

  validates_presence_of :tracker_id
  validates_uniqueness_of :tracker_id, :scope => :project_type_id
  attr_protected :id
end
