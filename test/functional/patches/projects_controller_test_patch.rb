class ProjectsControllerTest
  # define_method('test_get_copy') do
  #   @request.session[:user_id] = 1 # admin
  #   orig = Project.find(1)

  #   get :copy, :params => {
  #       :id => orig.id
  #     }
  #   assert_response :success

  #   assert_select 'textarea[name=?]', 'project[description]', :text => orig.description
  #   assert_select 'input[name=?][value=?]', 'project[enabled_module_names][]', 'issue_tracking', 0
  # end

 # define_method('test_create_should_preserve_modules_on_validation_failure') do
    # with_settings :default_projects_modules => ['issue_tracking', 'repository'] do
    #   @request.session[:user_id] = 1
    #   assert_no_difference 'Project.count' do
    #     post :create, :params => {
    #         :project => {
    #           :name => "blog",
    #           :identifier => "",
    #           :enabled_module_names => %w(issue_tracking news)
    #         }
    #       }
    #   end
    #   assert_response :success
    #   %w(issue_tracking news).each do |mod|
    #     assert_select 'input[name=?][value=?][checked=checked]', 'project[enabled_module_names][]', mod, 0
    #   end
    #   assert_select 'input[name=?][checked=checked]', 'project[enabled_module_names][]', 0
    # end
 # end
end