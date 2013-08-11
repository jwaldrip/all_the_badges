class UsersController < ApplicationController

  def show
    @user = User.find_or_fetch login: params[:user]
  end

end
