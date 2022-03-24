class LearningHoursController < ApplicationController

  def index
    @learning_hours = LearningHour.where(user_id: current_user.id)
  end

  def new
    @learning_hour = LearningHour.new
  end

  def create
    @learning_hour = LearningHour.new(learning_hours_params)
    respond_to do |format|
      if @learning_hour.save
        format.html { redirect_to volunteer_learning_hours_path(current_user.id), notice: "New entry was successfully created." }
      else
        format.html { render (:new), status: 404 }
        
      end
    end
  end

  def update
  end

  private

  def learning_hours_params
    params.require(:learning_hour).permit(:occurred_at, :duration_minutes, :duration_hours, :name, :user_id, :learning_type)
  end
end
