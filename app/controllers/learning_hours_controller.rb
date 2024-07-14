class LearningHoursController < ApplicationController
  before_action :set_learning_hour, only: %i[show edit update destroy]
  after_action :verify_authorized, except: :index # TODO add this back and fix all tests

  def index
    authorize LearningHour
    @learning_hours = policy_scope(LearningHour)
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
        format.html { redirect_to learning_hours_path, notice: "New entry was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
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
        format.html { redirect_to learning_hour_path(@learning_hour), notice: "Entry was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @learning_hour
    @learning_hour.destroy
    flash[:notice] = "Entry was successfully deleted."
    redirect_to learning_hours_path
  end

  private

  def set_learning_hour
    @learning_hour = LearningHour.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to learning_hours_path
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
