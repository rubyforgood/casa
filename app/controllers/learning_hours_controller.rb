class LearningHoursController < ApplicationController
  before_action :set_learning_hour, only: %i[show edit update destroy]
  after_action :verify_authorized, except: :index # TODO add this back and fix all tests

  def index
    @learning_hours = LearningHour.where(user_id: current_user.id)
  end

  def show
    authorize @learning_hour
  end

  def new
    authorize LearningHour
    @learning_hour = LearningHour.new
  end

  def create
    @learning_hour = LearningHour.new(learning_hours_params)
    authorize @learning_hour

    respond_to do |format|
      if @learning_hour.save
        format.html { redirect_to volunteer_learning_hours_path(volunteer_id: current_user.id), notice: "New entry was successfully created." }
      else
        format.html { render :new, status: 404 }
      end
    end
  end

  def edit
    authorize @learning_hour
  end

  def update
    authorize @learning_hour
    respond_to do |format|
      if @learning_hour.update(update_learning_hours_params)
        format.html { redirect_to volunteer_learning_hour_path, notice: "Entry was successfully updated." }
      else
        format.html { render :edit, status: 404 }
      end
    end
  end

  def destroy
    authorize @learning_hour
    @learning_hour.destroy
    flash[:notice] = "Entry was successfully deleted."
    redirect_to volunteer_learning_hours_path(volunteer_id: current_user.id)
  end

  private

  def set_learning_hour
    @learning_hour = LearningHour.find(params[:id])
  end

  def learning_hours_params
    params.require(:learning_hour).permit(:occurred_at, :duration_minutes, :duration_hours, :name, :user_id,
      :learning_hour_type_id, :learning_hour_topic_id)
  end

  def update_learning_hours_params
    params.require(:learning_hour).permit(:occurred_at, :duration_minutes, :duration_hours, :name,
      :learning_hour_type_id, :learning_hour_topic_id)
  end
end
