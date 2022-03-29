class LearningHoursController < ApplicationController
  before_action :set_volunteer
  before_action :set_learning_hour, only: %i[show edit update]

  def index
    @learning_hours = LearningHour.where(user_id: current_user.id)
  end

  def show
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

  def edit
  end

  def update

    respond_to do |format|
      if @learning_hour.update(update_learning_hours_params)
        format.html { redirect_to volunteer_learning_hour_path, notice: "Entry was successfully updated." }
      else
        format.html { render (:edit), status: 404 }
      end
    end
  end

  private

  def set_learning_hour
    @learning_hour = LearningHour.find(params[:id])
  end

  def set_volunteer
    @volunteer = current_user.id
  end

  def learning_hours_params
    params.require(:learning_hour).permit(:occurred_at, :duration_minutes, :duration_hours, :name, :user_id, :learning_type)
  end

  def update_learning_hours_params
    params.require(:learning_hour).permit(:occurred_at, :duration_minutes, :duration_hours, :name, :learning_type)
  end
end
