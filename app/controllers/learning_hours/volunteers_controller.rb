class LearningHours::VolunteersController < ApplicationController
  before_action :set_volunteer, only: :show
  after_action :verify_authorized

  def show
    authorize @volunteer
    @active_nav = "learning"
    @learning_hours = LearningHour.where(user: @volunteer)
    render layout: "casa_app"
  end

  private

  def set_volunteer
    @volunteer = User.includes(:learning_hours).find(params[:id])
  end
end
