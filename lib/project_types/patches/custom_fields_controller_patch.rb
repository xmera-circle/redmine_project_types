# frozen_string_literal: true

module ProjectTypes
  module Patches
    module CustomFieldsControllerPatch
      def self.prepended(base)
        base.extend(ClassMethods)
        base.prepend(InstanceMethods)
      end

      module ClassMethods; end

      module InstanceMethods
        def update
          saved = validate_custom_field_project_type_change

          if saved
            call_hook(:controller_custom_fields_edit_after_save, params: params, custom_field: @custom_field)
            respond_to do |format|
              format.html do
                flash[:notice] = l(:notice_successful_update)
                redirect_back_or_default edit_custom_field_path(@custom_field)
              end
              format.js { head 200 }
            end
          else
            respond_to do |format|
              format.html { render action: 'edit' }
              format.js { head 422 }
            end
          end
        end

        private

        def validate_custom_field_project_type_change
          @custom_field.safe_attributes = params[:custom_field]
          @custom_field.save
          saved = true
        rescue StandardError
          false
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless CustomFieldsController.included_modules.include?(ProjectTypes::Patches::CustomFieldsControllerPatch)
    CustomFieldsController.prepend(ProjectTypes::Patches::CustomFieldsControllerPatch)
  end
end
