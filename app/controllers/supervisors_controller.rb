class SupervisorsController < ApplicationController
  # Uses authenticate_user to redirect if no user is signed in
  # and must_be_admin_or_supervisor to check user's role is appropriate
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor

  def edit
    @supervisor = User.find(params[:id])

    unless can_update?
      redirect_to root_url
    end
  end

  def update
    @supervisor = User.find(params[:id])

    if can_update?
      if @supervisor.update(update_supervisor_params)
        redirect_to edit_supervisor_path(@supervisor), notice: "Supervisor was successfully updated."
      else
        render :edit
      end
    else
      redirect_to root_url
    end
  end

  private

  def can_update?
    current_user == @supervisor || current_user.casa_admin?
  end

  def update_supervisor_params
    if current_user.casa_admin?
      return UserParameters.new(params)
    end

    UserParameters.new(params).without_role
  end
end
