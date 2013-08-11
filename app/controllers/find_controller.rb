class FindController < ApplicationController

  def create
    user, repo = params[:query].split('/')
    if user.present? && repo.present?
      redirect_to_repo user, repo
    elsif user.present?
      redirect_to_user user
    else
      redirect_to :back, notice: 'Invalid Query'
    end
  end

  private

  def redirect_to_repo(user, repo)
    redirect_to repo_path(user: user, repo: repo)
  end

  def redirect_to_user(user)
    redirect_to user_path(user: user)
  end

end
