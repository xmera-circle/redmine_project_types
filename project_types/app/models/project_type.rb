class ProjectType < ActiveRecord::Base
  unloadable
  
  # Associated models
  has_many :projects_project_types
  has_many :projects, :through => :projects_project_types
  
  has_many :trackers, :through => :project_types_default_trackers
  has_many :project_types_default_trackers, :dependent => :delete_all
  
  has_many :project_types_default_modules, :dependent => :delete_all
    
  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  attr_protected :id
  acts_as_positioned

  scope :sorted, lambda { order(:position) }
  
  def <=>(project_type)
    position <=> project_type.position
  end
  
  def self.relation_order
    self.sorted.to_a
  end
  
end
