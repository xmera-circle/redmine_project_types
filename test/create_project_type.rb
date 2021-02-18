# frozen_string_literal: true

module ProjectTypes
  ##
  # Provide user login test
  #
  module CreateProjectType
    def project_type_create_params(associates)
      { project_type:
        { name: 'Lore ipsum',
          description: 'for testing',
          is_public: 0,
          default_member_role_id: 3,
          position: 4 }.merge(associates) }
    end
  end
end
