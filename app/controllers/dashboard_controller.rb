class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard

    @volunteers = policy_scope(User.volunteer)
    @casa_cases = policy_scope(CasaCase.all)
    @case_contacts = policy_scope(CaseContact.all)
  end
end
