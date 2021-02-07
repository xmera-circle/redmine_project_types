class TrackersControllerTest
  define_method('test_edit') do
    Tracker.find(1).project_ids = [1, 3]

    get :edit, :params => {:id => 1}
    assert_response :success

    assert_select 'input[name=?][value="1"][checked=checked]', 'tracker[project_ids][]', 0
    assert_select 'input[name=?][value="2"]:not([checked])', 'tracker[project_ids][]', 0

    assert_select 'input[name=?][value=""][type=hidden]', 'tracker[project_ids][]', 0
  end
end