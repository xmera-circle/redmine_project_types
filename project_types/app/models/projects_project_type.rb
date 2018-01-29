class ProjectsProjectType < ActiveRecord::Base
  unloadable
   
  # Associated models
  belongs_to :project
  belongs_to :project_type
 
  # Validations   
  validates_uniqueness_of :project_id
  
  self.primary_key = :project_id

end
