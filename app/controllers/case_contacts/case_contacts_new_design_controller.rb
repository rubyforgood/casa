class CaseContacts::CaseContactsNewDesignController < ApplicationController
  include LoadsCaseContacts

  def index
    load_case_contacts
  end

  def datatable
    authorize CaseContact
    case_contacts = policy_scope(current_organization.case_contacts)
    datatable = CaseContacDatatable.new case_contacts, params

    render json: datatable
  end
end
