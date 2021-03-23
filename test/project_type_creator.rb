# frozen_string_literal: true

module ProjectTypes
  ##
  # Provide user login test
  #
  module ProjectTypeCreator
    def find_project_type(id:)
      project_type = Project.find(id)
      project_type.is_master = true
      project_type.save
      project_type
    end

    def project_type_params(name:)
      { project: project_type_attributes(name: name) }
    end

    def create_project_type(name:)
      ProjectType.create(project_type_attributes(name: name))
    end

    def project_type_attributes(name:)
      { name: name,
        identifier: name.parameterize,
        is_master: true }
    end
  end
end
