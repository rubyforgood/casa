class CaseContacts::FormController < ApplicationController
  include Wicked::Wizard

  before_action :set_case_contact
  before_action :set_contact_types
  before_action :require_organization!

  steps :select_contact_types, :contact_details, :travel_details, :notes

  # ===== NOTES =====
  # Need to map the steps of the form
  # Right now it will create one case contact per casa case at a time

  def show
    render_wizard
  end

  def update
    @case_contact.save(context: step)

    render_wizard @case_contact
  end
end

private

def set_case_contact
  if current_organization.case_contacts.exists?(params[:case_contact_id])
    @case_contact = authorize(current_organization.case_contacts.find(params[:case_contact_id]))
  else
    redirect_to authenticated_user_root_path
  end
end

def set_contact_types
  @contact_types = ContactType.for_organization(current_organization)
end

def update_case_contact_for_every_selected_casa_case(selected_cases)
  selected_cases.map do |casa_case|
    casa_case.case_contacts.update(update_case_contact_params.except(:casa_case_attributes))
  end
end

def update_case_contact_params
  # Updating a case contact should not change its original creator
  CaseContactParameters.new(params)
end

def current_organization_groups
  current_organization.contact_type_groups
    .joins(:contact_types)
    .where(contact_types: {active: true})
    .uniq
end

def all_case_contacts
  policy_scope(current_organization.case_contacts).includes(:creator, contact_types: :contact_type_group)
end

def update_or_create_additional_expense(all_ae_params, cc)
  all_ae_params.each do |ae_params|
    id = ae_params[:id]
    current = AdditionalExpense.find(:id)
    if current
      current.assign_attributes(other_expense_amount: ae_params[:other_expense_amount], other_expenses_describe: ae_params[:other_expenses_describe])
      save_or_add_error(current, cc)
    else
      create_new_exp = cc.additional_expenses.build(ae_params)
      save_or_add_error(create_new_exp, cc)
    end
  end
end

def save_or_add_error(obj, case_contact)
  obj.valid? ? obj.save : case_contact.errors.add(:base, obj.errors.full_messages.to_sentence)
end

def update_volunteer_address(volunteer = current_user)
  content = create_case_contact_params.dig(:casa_case_attributes, :volunteers_attributes, "0", :address_attributes, :content)
  return if content.blank?
  if volunteer.address
    volunteer.address.update!(content: content)
  else
    volunteer.address = Address.new(content: content)
    volunteer.save!
  end
end
