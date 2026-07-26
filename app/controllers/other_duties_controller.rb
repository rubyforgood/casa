class OtherDutiesController < ApplicationController
  layout "casa_app"
  before_action -> { @active_nav = "other_duties" }

  before_action :set_other_duty, except: [:new, :create, :index]
  before_action :convert_duration_minutes, only: [:update, :create]
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

  def index
    authorize OtherDuty

    # Whose duties this user reviews: an admin sees every org volunteer's, a supervisor their
    # (active) assigned volunteers', a volunteer only their own.
    volunteers = if current_user.casa_admin?
      policy_scope(Volunteer)
    elsif current_user.supervisor?
      current_user.volunteers
    else
      [current_user]
    end

    # A flat, most-recent-first log of entries (replacing the per-volunteer grouped tables).
    duties = OtherDuty.where(creator: volunteers).includes(:creator).order(occurred_at: :desc).to_a

    unless current_user.volunteer?
      # Type-ahead volunteer search, mirroring the learning-hours roster (searchable-select).
      @roster_names = duties.map { |duty| duty.creator.display_name }.compact.uniq.sort
      if params[:search].present?
        query = params[:search].strip.downcase
        duties = duties.select { |duty| duty.creator.display_name.to_s.downcase.include?(query) }
      end
    end

    per_page = 25
    page = params[:page].to_i.clamp(1, [(duties.size.to_f / per_page).ceil, 1].max)
    @pagy = Pagy.new(count: duties.size, page: page, limit: per_page)
    @other_duties = duties[@pagy.offset, per_page] || []
  end

  def new
    authorize OtherDuty
    @other_duty = OtherDuty.new
  end

  def create
    authorize OtherDuty
    @other_duty = OtherDuty.new(other_duty_params)

    if @other_duty.save
      redirect_to other_duties_path, notice: "Duty was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @other_duty
  end

  def update
    authorize @other_duty

    if @other_duty.update(other_duty_params)
      redirect_to other_duties_path, notice: "Duty was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def convert_duration_minutes
    duration_hours = params[:other_duty][:duration_hours].to_i
    converted_duration_hours = duration_hours * 60
    duration_minutes = params[:other_duty][:duration_minutes].to_i
    params[:other_duty][:duration_minutes] = (converted_duration_hours + duration_minutes).to_s
  end

  def other_duty_params
    params.require(:other_duty).permit(:occurred_at, :creator_type, :duration_minutes, :notes).merge({creator_id: current_user.id})
  end

  def set_other_duty
    @other_duty = OtherDuty.find(params[:id])
  end
end
