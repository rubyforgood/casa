class LearningHours::VolunteersController < ApplicationController
  def show
    volunteer = User.includes(:learning_hours).find(params[:id])
    authorize volunteer
    @learning_hours = LearningHour.where(user: volunteer)
  end
end
