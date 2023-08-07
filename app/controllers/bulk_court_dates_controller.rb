class BulkCourtDatesController < ApplicationController
  include CourtDateParams

  before_action :require_organization!

  def new
    authorize :application, :admin_or_supervisor?

    @court_date = CourtDate.new
  end

  def create
    authorize :application, :admin_or_supervisor?

    case_group_id = params[:court_date][:case_group_id]
    if case_group_id.empty?
      @court_date = build_court_date_with_error_message
      render :new
      return
    end

    case_group = current_organization.case_groups.find(case_group_id)
    court_dates = build_court_dates(case_group)

    court_date_with_error = create_court_dates(court_dates)

    if court_date_with_error
      @court_date = court_date_with_error
      render :new
    else
      redirect_to new_bulk_court_date_path, notice: "#{court_dates.size} #{"court date".pluralize(court_dates.size)} created!"
    end
  end

  private

  def build_court_date_with_error_message
    court_date = CourtDate.new(court_date_params(nil))
    court_date.errors.add(:base, "Case group must be selected.")
    court_date
  end

  def build_court_dates(case_group)
    case_group.casa_cases.map do |casa_case|
      CourtDate.new(court_date_params(casa_case).merge(casa_case: casa_case))
    end
  end

  def create_court_dates(court_dates)
    court_date_with_error = nil
    ActiveRecord::Base.transaction do
      court_dates.each do |court_date|
        if !court_date.save
          court_date_with_error = court_date
          raise ActiveRecord::Rollback
        end
      end
    end
    court_date_with_error
  end
end
