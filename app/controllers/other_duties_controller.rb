class OtherDutiesController < ApplicationController
  before_action :set_other_duty, except: [:new, :create, :index]
  before_action :convert_duration_minutes, only: [:update, :create]

  def index
    authorize OtherDuty

    @volunteer_duties = if current_user.casa_admin?
      generate_other_duty_list(policy_scope(Volunteer))
    else
      generate_other_duty_list(current_user.volunteers)
    end
  end

  def new
    authorize OtherDuty
    @other_duty = OtherDuty.new
  end

  def create
    authorize OtherDuty
    @other_duty = OtherDuty.new(other_duty_params)

    if @other_duty.save
      redirect_to casa_cases_path, notice: "Duty was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @other_duty
  end

  def update
    authorize @other_duty

    if @other_duty.update(other_duty_params)
      redirect_to casa_cases_path, notice: "Duty was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def convert_duration_minutes
    duration_hours = params[:other_duty][:duration_hours].to_i
    converted_duration_hours = duration_hours * 60
    duration_minutes = params[:other_duty][:duration_minutes].to_i
    params[:other_duty][:duration_minutes] = (converted_duration_hours + duration_minutes).to_s
  end

  def generate_other_duty_list(volunteers)
    return [] if no_other_duties_for(volunteers)
    volunteers.map do |volunteer|
      {
        volunteer: volunteer,
        other_duties: volunteer.other_duties
      }
    end
  end

  def no_other_duties_for(volunteers)
    no_duties_found = true
    volunteers.each do |volunteer|
      if volunteer.other_duties.present?
        no_duties_found = false
      end
    end
    no_duties_found
  end

  def other_duty_params
    params.require(:other_duty).permit(:occurred_at, :creator_type, :duration_minutes, :notes).merge({creator_id: current_user.id})
  end

  def set_other_duty
    @other_duty = OtherDuty.find(params[:id])
  end
end
