require_dependency 'project'

module ProjectPatch
  
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      # Associatons
      has_one :projects_project_type, dependent: :destroy
      accepts_nested_attributes_for :projects_project_type
      
      # Callbacks
      after_create :project_types_default_values
      
      # Core Extensions (for class methods) --- no method defined yet
      #self.singleton_class.send(:alias_method, :project_types_next_identifier, :next_identifier)
 
      # Core Extensions (for instance methods)
      alias_method_chain :add_default_member, :project_type_default
          
    end
  end
  
  module ClassMethods
    
  end # module ClassMethods
  
  module InstanceMethods

    def project_types_default_values
      if self.projects_project_type.present? 
        if self.projects_project_type.project_type_id.present?
          # Delete all multi choice attributes first
          self.enabled_module_names = []
          self.trackers = []
          self.is_public = false
          self.save
            
          # Set all attributes according the underlying project type
          project_type_id = self.projects_project_type.project_type.id
          project_type = ProjectType.find(project_type_id)
          default = ProjectTypesDefaultTracker.where(project_type_id: project_type_id).pluck(:tracker_id).map(&:to_s)

          if project_type.is_public
            self.is_public = true
            self.save
          end
          
          self.enabled_module_names = ProjectTypesDefaultModule.where(project_type_id: project_type_id).pluck(:name)
          
          if default.is_a?(Array)
            self.trackers = Tracker.where(:id => default.map(&:to_i)).sorted.to_a
          else
            self.trackers = Tracker.sorted.to_a
          end
        end
      end
    end
    
   # Adds user as a project member with the default role of the project type
   # Used for when a non-admin user creates a project
   def add_default_member_with_project_type_default(user)
      if self.projects_project_type.present? 
        if self.projects_project_type.project_type_id.present?
          project_type_id = self.projects_project_type.project_type.id
          project_type = ProjectType.find(project_type_id)
          role_id = project_type.default_user_role_id
              
          role = Role.givable.find_by_id(role_id) || Role.givable.first
          member = Member.new(:project => self, :principal => user, :roles => [role])
          self.members << member
          self.save
          member
        end
      else
        add_default_member_without_project_type_default(user)
      end
    end  
    
    def type
      ProjectType.find(self.projects_project_type.project_type_id)
    end
    
    def relations
      ProjectsRelation.relations(self)
    end
    
    def relations?
      ProjectsRelation.relations?(self)
    end
    
    def relations_down
      ProjectsRelation.relations_down(self)
    end
    
    def relations_down?
      ProjectsRelation.relations_down?(self)
    end
    
    def relations_up
      ProjectsRelation.relations_up(self)
    end
    
    def relations_up?
      ProjectsRelation.relations_up?(self)
    end
  end # module InstanceMethods
  
end # module ProjectPatch

Project.send(:include, ProjectPatch)