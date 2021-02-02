class EnabledProjectTypeModule < ActiveRecord::Base
  belongs_to :project_type
  acts_as_watchable

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_type_id

end