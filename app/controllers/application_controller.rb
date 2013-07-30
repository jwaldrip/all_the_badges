class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #rescue_from Github::Error::NotFound, with: :invalid_user_or_repo

  def invalid_user_or_repo
    redirect_to :root, notice: 'Invalid User or Repo'
  end

end
