class ApiEngineBaseController < ApplicationController
  helper_method :current_user_session, :current_user

  private
    def current_user_session
      @current_user_session ||= UserSession.find
    end

    def current_user
      @current_user ||= current_user_session &&  current_user_session.user_mockup
    end

end