module ProjectTypesHelper
 def default_modules_multiselect(project_type_id, choices, label,options={})
    
    default_modules = ProjectTypesDefaultModule.where(project_type_id: project_type_id).pluck(:name)
    default_modules = [] unless default_modules.is_a?(Array)

    content_tag("label", l(label) ) +
      hidden_field_tag("project_types_default_module[name][]", '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
             "project_types_default_module[name][]",
             value,
             default_modules.include?(value),
             :id => nil
           ) + text.to_s,
          :class => 'block'
         )
      end.join.html_safe
  end
  
  def default_trackers_multiselect(project_type_id, choices, label,options={})
    
    default_trackers = ProjectTypesDefaultTracker.where(project_type_id: project_type_id).pluck(:tracker_id)
    default_trackers = [] unless default_trackers.is_a?(Array)

    content_tag("label", l(label) ) +
      hidden_field_tag("project_types_default_tracker[tracker_id][]", '').html_safe +
      choices.collect do |choice|
        text, value = (choice.is_a?(Array) ? choice : [choice, choice])
        content_tag(
          'label',
          check_box_tag(
             "project_types_default_tracker[tracker_id][]",
             value,
             default_trackers.include?(value),
             :id => nil
           ) + text.to_s,
          :class => 'block'
         )
      end.join.html_safe
  end
  
  def create_multi_default_modules(record_set, parameters)
    record_set.delete_all
      
        parameters[:name].each do |i|
            if !i.empty?
              record_set.create!( name: i)
            end
        end
  end
  
  def create_multi_default_trackers(record_set, parameters)
    record_set.delete_all
      
        parameters[:tracker_id].each do |i|
            if !i.empty?
              record_set.create!( tracker_id: i)
            end
        end
  end
end
