class CustomFieldsControllerTest
  define_method("test_new_issue_custom_field") do
    get :new, :params => {
        :type => 'IssueCustomField'
      }
    assert_response :success

    assert_select 'form#custom_field_form' do
      assert_select 'select#custom_field_field_format[name=?]', 'custom_field[field_format]' do
        assert_select 'option[value=user]', :text => 'User'
        assert_select 'option[value=version]', :text => 'Version'
      end

      # Visibility
      assert_select 'input[type=radio][name=?]', 'custom_field[visible]', 2
      assert_select 'input[type=checkbox][name=?]', 'custom_field[role_ids][]', 3
      # Projects
      byebug
      assert_select 'input[type=checkbox][name=?]', 'custom_field[project_ids][]', 0
      assert_select 'input[type=hidden][name=?]', 'custom_field[project_ids][]', 0
      assert_select 'input[type=hidden][name=type][value=IssueCustomField]'
    end
  end
end