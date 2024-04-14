class LearningHours::VolunteersController < ApplicationController
  before_action :set_volunteer, only: :show
  after_action :verify_authorized

  def show
    authorize @volunteer
    @learning_hours = LearningHour.where(user: @volunteer)
  end

  private

  def set_volunteer
    @volunteer = User.includes(:learning_hours).find(params[:id])
  end
end
