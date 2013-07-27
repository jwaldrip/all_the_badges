class ReposController < ApplicationController

  def show
    @repo = Repo.find params[:user], params[:repo]
  end

end
