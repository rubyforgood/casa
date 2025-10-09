class CaseContacts::CaseContactsNewDesignController < ApplicationController
  include LoadsCaseContacts

  before_action :check_feature_flag

  def index
    load_case_contacts
  end

  def datatable
    authorize CaseContact
    case_contacts = policy_scope(current_organization.case_contacts)
    datatable = CaseContactDatatable.new case_contacts, params

    render json: datatable
  end

  private

  def check_feature_flag
    unless Flipper.enabled?(:new_case_contact_table)
      redirect_to case_contacts_path, alert: "This feature is not available."
    end
  end
end
