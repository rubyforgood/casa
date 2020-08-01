# frozen_string_literal: true

class SupervisorsController < ApplicationController
  # Uses authenticate_user to redirect if no user is signed in
  # and must_be_admin_or_supervisor to check user's role is appropriate
  before_action :authenticate_user!
  before_action :must_be_admin_or_supervisor
  before_action :must_be_admin, only: [:new, :create]
  before_action :available_volunteers, only: [:new, :create, :edit, :update]

  def new
    @supervisor = User.new
  end

  def create
    @supervisor = User.new(supervisor_params.merge(supervisor_values))

    if @supervisor.save
      # @supervisor.invite!
      redirect_to edit_supervisor_path(@supervisor)
    else
      render new_supervisor_path
    end
  end

  def edit
    @supervisor = User.find(params[:id])
    @assigned_volunteers = @supervisor.supervisor_volunteers.sort_by { |sv| sv.volunteer.display_name }

    redirect_to root_url unless can_view_update_page?
  end

  def update
    @supervisor = User.find(params[:id])

    if can_update_fields?
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

  def available_volunteers
    @available_volunteers = User.volunteers_with_no_supervisor(current_user.casa_org)
  end

  def supervisor_values
    {role: "supervisor", password: "123456", casa_org_id: current_user.casa_org_id}
  end

  def supervisor_params
    params.require(:user).permit(:display_name, :email, volunteer_ids: [], supervisor_volunteer_ids: [])
  end

  def can_view_update_page?
    # supervisor must be able to view edit supervisor page so they can change volunteer assignments
    current_user.supervisor? || current_user.casa_admin?
  end

  def can_update_fields?
    current_user == @supervisor || current_user.casa_admin?
  end

  def update_supervisor_params
    return UserParameters.new(params) if current_user.casa_admin?

    UserParameters.new(params).without_role
  end
end
