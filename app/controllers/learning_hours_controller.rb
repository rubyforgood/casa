class LearningHoursController < ApplicationController
  before_action :set_learning_hour, only: %i[show edit update destroy]
  before_action :set_active_nav, only: %i[index show new create edit update]
  after_action :verify_authorized, except: :index # TODO add this back and fix all tests

  def index
    authorize LearningHour
    rows = LearningHoursDashboardRowsService
      .new(current_user, policy_scope(LearningHour))
      .perform

    if current_user.volunteer?
      @learning_hours = rows
    else
      # Supervisor/admin roster: rows are one per volunteer (an array for supervisors, a
      # relation for admins). Paginate uniformly as an array with Pagy.
      rows = rows.to_a
      per_page = 25
      page = params[:page].to_i.clamp(1, [(rows.size.to_f / per_page).ceil, 1].max)
      @pagy = Pagy.new(count: rows.size, page: page, limit: per_page)
      @learning_hours = rows[@pagy.offset, per_page] || []
    end

    render :index, layout: "casa_app"
  end

  def show
    authorize @learning_hour
    render layout: "casa_app"
  end

  def new
    authorize LearningHour
    @learning_hour = LearningHour.new
    render layout: "casa_app"
  end

  def create
    @learning_hour = LearningHour.new(learning_hours_params)
    authorize @learning_hour

    respond_to do |format|
      if @learning_hour.save
        format.html { redirect_to learning_hours_path, notice: "New entry was successfully created." }
      else
        format.html { render :new, status: :unprocessable_content, layout: "casa_app" }
      end
    end
  end

  def edit
    authorize @learning_hour
    render layout: "casa_app"
  end

  def update
    authorize @learning_hour
    respond_to do |format|
      if @learning_hour.update(update_learning_hours_params)
        format.html { redirect_to learning_hour_path(@learning_hour), notice: "Entry was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_content, layout: "casa_app" }
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

  def set_active_nav
    @active_nav = "learning"
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
