class ReposController < ApplicationController

  def show
    @repo = Repo.find_or_fetch user: user, name: params[:repo]
  end

  private

  def user
    @user ||= User.find_or_fetch(login: params[:user])
  end

  helper_method :user

end
