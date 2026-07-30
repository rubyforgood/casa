class LearningHoursController < ApplicationController
  before_action :set_learning_hour, only: %i[show edit update destroy]
  before_action :set_active_nav, only: %i[index show new create edit update]
  after_action :verify_authorized, except: :index # TODO add this back and fix all tests

  def index
    authorize LearningHour
    set_period
    rows = LearningHoursDashboardRowsService
      .new(current_user, policy_scope(LearningHour), @period)
      .perform

    if current_user.volunteer?
      @learning_hours = rows
    else
      # Supervisor/admin roster: rows are one per volunteer (an array for supervisors, a
      # relation for admins). Paginate uniformly as an array with Pagy.
      rows = rows.to_a
      @roster_names = rows.map(&:display_name).compact.uniq.sort
      if params[:search].present?
        query = params[:search].strip.downcase
        rows = rows.select { |row| row.display_name.to_s.downcase.include?(query) }
      end
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

  # The roster column is bounded by a date range the user can change. It defaults to the calendar
  # year to date, which is what the column header always claimed ("Time completed this year") even
  # though nothing filtered on occurred_at, so the totals were all-time.
  # Learning hours cannot occur before 1989-01-01 (LearningHour validates that) or in the future, so
  # clamp to that window: a hand-edited or mistyped param would otherwise put a nonsense year in the
  # column header ("since February 2, 0730" -- Date.parse happily accepts it).
  PERIOD_FLOOR = Date.new(1989, 1, 1)

  def set_period
    @period_from = parse_date(params[:from]) || Date.current.beginning_of_year
    @period_to = parse_date(params[:to]) || Date.current
    @period_from, @period_to = @period_to, @period_from if @period_from > @period_to
    @period_from = @period_from.clamp(PERIOD_FLOOR, Date.current)
    @period_to = @period_to.clamp(PERIOD_FLOOR, Date.current)
    @period = @period_from..@period_to
  end

  def parse_date(value)
    Date.parse(value.to_s)
  rescue Date::Error
    nil
  end

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
