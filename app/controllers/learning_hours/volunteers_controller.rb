class LearningHours::VolunteersController < ApplicationController
  # TODO: Add Pundit authorization

  def show
    volunteer = User.includes(:learning_hours).find(params[:id])
    @learning_hours = LearningHour.where(user: volunteer)
  end
end
