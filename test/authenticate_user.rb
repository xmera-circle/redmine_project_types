module RedmineProjectTypes
  ##
  # Provide user login test
  #
  module AuthenticateUser
    def log_user(login, password)
      get_login_page
      log_user_in(login, password)
      assert_equal login, User.find(user_session_id).login
    end

    module_function

    def get_login_page
      User.anonymous
      get '/login'
      assert_nil user_session_id
      assert_response :success
    end

    def user_session_id
      session[:user_id]
    end

    def log_user_in(login, password)
      post '/login', params: {
        username: login,
        password: password
      }
    end
  end
end
