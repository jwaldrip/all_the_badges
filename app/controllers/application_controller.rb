class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from Github::Error::NotFound, with: :invalid_user_or_repo

  def invalid_user_or_repo
    redirect_to :root, notice: 'Invalid User or Repo'
  end

end
