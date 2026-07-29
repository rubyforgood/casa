class CasaCasesController < ApplicationController
  before_action :set_casa_case, only: %i[show edit update deactivate reactivate copy_court_orders]
  before_action :set_contact_types, only: %i[new edit update create deactivate reactivate]
  before_action -> { @active_nav = "cases" }, only: %i[edit update deactivate reactivate]
  before_action :require_organization!
  after_action :verify_authorized

  SORT_COLUMNS = %w[case_number next_court_date status transition assigned].freeze

  def index
    authorize CasaCase
    @active_nav = "cases"
    @sort = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "case_number"
    @direction = (params[:direction] == "desc") ? "desc" : "asc"
    org_cases = current_user.casa_org.casa_cases.includes(:assigned_volunteers, :court_dates)
    scope = policy_scope(org_cases)
    scope = filter_casa_cases(scope) if policy(CasaCase).can_see_filters?
    @pagy, @casa_cases = pagy(order_casa_cases(scope))
    render :index, layout: "casa_app"
  end

  def show
    authorize @casa_case
    @active_nav = "cases"

    respond_to do |format|
      format.html { render layout: "casa_app" }
      format.csv do
        case_contacts = @casa_case.decorate.case_contacts_ordered_by_occurred_at
        csv = CaseContactsExportCsvService.new(case_contacts, CaseContactReport::COLUMNS).perform
        send_data csv, filename: case_contact_csv_name(case_contacts)
      end
      format.xlsx do
        filename = @casa_case.case_number + "-case-contacts-" + Time.now.strftime("%Y-%m-%d") + ".xlsx"
        response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
      end
    end
  end

  def new
    @casa_case = CasaCase.new(casa_org: current_organization)
    authorize @casa_case
    @active_nav = "cases"
    render layout: "casa_app"
  end

  def edit
    @siblings_casa_cases = CasaCasePolicy::Scope.new(current_user, @casa_case).sibling_cases
    authorize @casa_case
    render layout: "casa_app"
  end

  def create
    @casa_case = CasaCase.new(
      casa_case_create_params.merge(
        casa_org: current_organization
      )
    )

    authorize @casa_case

    @casa_case.validate_contact_type = true

    if @casa_case.save
      respond_to do |format|
        format.html { redirect_to @casa_case, notice: "CASA case was successfully created." }
        format.json { render json: @casa_case, status: :created }
      end
    else
      set_contact_types
      @empty_court_date = court_date_unknown?
      @active_nav = "cases"
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content, layout: "casa_app" }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_content }
      end
    end
  end

  def update
    authorize @casa_case
    original_attributes = @casa_case.full_attributes_hash
    @casa_case.validate_contact_type = true unless current_role == "Volunteer"
    if @casa_case.update_cleaning_contact_types(casa_case_update_params)
      updated_attributes = @casa_case.full_attributes_hash
      changed_attributes_list = CasaCaseChangeService.new(original_attributes, updated_attributes).calculate

      respond_to do |format|
        format.html { redirect_to edit_casa_case_path, notice: "CASA case was successfully updated.#{changed_attributes_list}" }
        format.json { render json: @casa_case, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_content, layout: "casa_app" }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_content }
      end
    end
  end

  def deactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.deactivate
      respond_to do |format|
        format.html do
          flash_message = "Case #{@casa_case.case_number} has been deactivated."
          redirect_to edit_casa_case_path(@casa_case), notice: flash_message
        end

        format.json do
          render json: "Case #{@casa_case.case_number} has been deactivated.", status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_content, layout: "casa_app" }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_content }
      end
    end
  end

  def reactivate
    authorize @casa_case, :update_case_status?

    if @casa_case.reactivate
      respond_to do |format|
        format.html do
          flash_message = "Case #{@casa_case.case_number} has been reactivated."
          redirect_to edit_casa_case_path(@casa_case), notice: flash_message
        end

        format.json do
          render json: "Case #{@casa_case.case_number} has been reactivated.", status: :ok
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_content, layout: "casa_app" }
        format.json { render json: @casa_case.errors.full_messages, status: :unprocessable_content }
      end
    end
  end

  def copy_court_orders
    authorize @casa_case, :update_court_orders?
    CasaCase.find_by_case_number(params[:case_number_cp]).case_court_orders.each do |court_order|
      dup_court_order = court_order.dup
      dup_court_order.save
      @casa_case.case_court_orders.append dup_court_order
    end
    flash[:notice] = "Court orders have been copied."
  end

  private

  # Orders the cases index by the whitelisted ?sort= column and ?direction=. Derived
  # columns (next court date, assigned volunteer) use correlated subqueries; a secondary
  # sort by case number keeps pagination stable.
  def order_casa_cases(scope)
    today = ActiveRecord::Base.connection.quote(Date.current)
    clause =
      case @sort
      when "status" then "casa_cases.active"
      when "transition" then "casa_cases.birth_month_year_youth"
      when "next_court_date"
        "(SELECT MIN(court_dates.date) FROM court_dates WHERE court_dates.casa_case_id = casa_cases.id AND court_dates.date >= #{today})"
      when "assigned"
        "(SELECT MIN(users.display_name) FROM case_assignments JOIN users ON users.id = case_assignments.volunteer_id WHERE case_assignments.casa_case_id = casa_cases.id AND case_assignments.active)"
      else "casa_cases.case_number"
      end
    # Re-derive the direction as a local literal so the SQL string is built only from a fixed
    # allow-list (clause is a case of literals; direction is one of two) -- also clears brakeman.
    direction = (@direction == "desc") ? "DESC" : "ASC"
    scope = scope.order(Arel.sql("#{clause} #{direction} NULLS LAST"))
    scope = scope.order(case_number: :asc) unless @sort == "case_number"
    scope
  end

  # Server-side filtering for the cases index (admins/supervisors). Params come from the
  # filter bar selects; volunteers never reach this. Status defaults to active.
  def filter_casa_cases(scope)
    if params[:search].present?
      term = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search].strip)}%"
      scope = scope.where(
        "casa_cases.case_number ILIKE :term OR EXISTS (SELECT 1 FROM case_assignments ca " \
        "JOIN users u ON u.id = ca.volunteer_id WHERE ca.casa_case_id = casa_cases.id AND ca.active " \
        "AND u.display_name ILIKE :term)",
        term: term
      )
    end

    scope = case params[:status]
    when "inactive" then scope.inactive
    when "all" then scope
    else scope.active
    end

    case params[:assigned]
    when "assigned" then scope = scope.where(id: CaseAssignment.active.select(:casa_case_id))
    when "unassigned" then scope = scope.where.not(id: CaseAssignment.active.select(:casa_case_id))
    end

    case params[:transition]
    when "yes" then scope = scope.is_transitioned
    when "no" then scope = scope.where.not(id: current_user.casa_org.casa_cases.is_transitioned.select(:id))
    end

    case params[:prefix]
    when "CINA" then scope = scope.where("case_number ILIKE ?", "CINA%")
    when "TPR" then scope = scope.where("case_number ILIKE ?", "TPR%")
    when "None" then scope = scope.where.not("case_number ILIKE ? OR case_number ILIKE ?", "CINA%", "TPR%")
    end

    scope
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_casa_case
    @casa_case = current_organization.casa_cases.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to casa_cases_path, notice: "Sorry, you are not authorized to perform this action." }
      format.json { render json: {error: "Sorry, you are not authorized to perform this action."}, status: :not_found }
    end
  end

  # Only allow a list of trusted parameters through.
  def casa_case_params
    params.require(:casa_case).permit(
      :case_number,
      :birth_month_year_youth,
      :date_in_care,
      :court_report_due_date,
      :empty_court_date,
      contact_type_ids: [],
      court_dates_attributes: [:date],
      case_assignments_attributes: [:volunteer_id]
    )
  end

  def casa_case_create_params
    create_params = casa_case_params
    create_params = create_params.except(:court_dates_attributes) if court_date_unknown?
    create_params.except(:empty_court_date)
  end

  # Separate params so only admins can update the case_number
  def casa_case_update_params
    params.require(:casa_case).permit(policy(@casa_case).permitted_attributes)
  end

  def set_contact_types
    @contact_types = current_organization.contact_types
    @selected_contact_type_ids = (!@casa_case.nil?) ? @casa_case.contact_type_ids : []
  end

  def case_contact_csv_name(case_contacts)
    casa_case_number = case_contacts&.first&.casa_case&.case_number
    current_date = Time.now.strftime("%Y-%m-%d")

    "#{casa_case_number.nil? ? "" : casa_case_number + "-"}case-contacts-#{current_date}.csv"
  end

  def court_date_unknown?
    casa_case_params[:empty_court_date] == "1"
  end
end
