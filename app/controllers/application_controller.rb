class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from Github::Error::NotFound, with: :invalid_user_or_repo

  private

  def invalid_user_or_repo
    redirect_to :root, notice: 'Invalid User or Repo'
  end

  def application_repo
    @application_repo ||= Repo.find_or_fetch user: application_user, name: 'all_the_badges'
  end

  def application_user
    @application_user ||= User.find_or_fetch login: 'jwaldrip'
  end

  helper_method :application_repo

end
