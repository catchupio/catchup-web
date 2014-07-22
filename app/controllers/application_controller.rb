class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :signed_in?

  def current_user
    @current_user ||= User.find_by(email: session[:current_user])
  end

  def signed_in?
    current_user != nil
  end
end
