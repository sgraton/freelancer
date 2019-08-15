class UsersController < ApplicationController
  before_action :authenticate_user!

  def dashboard
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = current_user
    if @user.update_attributes(current_users_params)
      flash[:notice] = "Saved."
    else
      flash[:alert] = "Cannot update."
    end
    redirect_to dashboard_path
  end

  private
  def current_users_params
    params.require(:user).permit(:from, :about, :status, :language, :avatar)
  end
end
