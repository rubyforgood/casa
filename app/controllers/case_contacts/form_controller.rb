class CaseContacts::FormController < ApplicationController
  include Wicked::Wizard

  before_action :find_and_authorize_case_contact, only: %i[show update]

  steps :select_cases, :select_contact_types, :contact_details, :travel_details, :notes

  def show
    @casa_cases = policy_scope(current_organization.casa_cases)

    # Select the most likely case option
    # - If there are cases defined in the params, select those cases (often coming from the case page)
    # - If there is only one case, select that case
    # - If there are no hints, let them select their case
    @selected_cases =
      if params.dig(:case_contact, :casa_case_id).present?
        @casa_cases.where(id: params.dig(:case_contact, :casa_case_id))
      elsif @casa_cases.count == 1
        @casa_cases[0, 1]
      else
        []
      end

    @selected_case_contact_types = @casa_cases.flat_map(&:contact_types)

    @current_organization_groups =
      if @selected_case_contact_types.present?
        @selected_case_contact_types.map(&:contact_type_group).uniq
      else
        current_organization
          .contact_type_groups
          .joins(:contact_types)
          .where(contact_types: {active: true})
          .alphabetically
          .uniq
      end

    # TODO: Do we want this logic?
    jump_to(:select_cases) if step.nil?

    render_wizard @case_contact
  end

  def update
    @case_contact.save(context: step)

    render_wizard @case_contact
  end

  def create
    params = CaseContactParameters.new(params, creator: current_user)
    @case_contact = CaseContact.new(params)
    authorize @case_contact
    redirect_to wizard_path(steps.first, case_contact_id: @case_contact.id)
  end
end

private

def case_contact_params(step)
  params.require(:case_contact).permit(helpers.permitted_attributes[step])
end

def find_and_authorize_case_contact
  @case_contact ||= CaseContact.find(params[:case_contact_id])
  authorize @case_contact, :edit?
end
