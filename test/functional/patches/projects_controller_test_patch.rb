class ProjectsControllerTest
  define_method('test_show_should_not_display_blank_custom_fields_with_multiple_values') do
    f1 = ProjectCustomField.generate! :field_format => 'list', :possible_values => %w(Foo Bar), :multiple => true
    f2 = ProjectCustomField.generate! :field_format => 'list', :possible_values => %w(Baz Qux), :multiple => true
    project = Project.generate!(:custom_field_values => {f2.id.to_s => %w(Qux)})

    get :show, :params => {
        :id => project.id
      }
    assert_response :success

    assert_select 'li', :text => /#{f1.name}/, :count => 0
    assert_select 'li', :text => /#{f2.name}/, :count => 0
  end

  define_method('test_show_should_display_visible_custom_fields') do
    ProjectCustomField.find_by_name('Development status').update_attribute :visible, true
    get :show, :params => {
        :id => 'ecookbook'
      }
    assert_response :success

    assert_select 'li[class=?]', 'cf_3', :text => /Development status/, :count => 0
  end
end