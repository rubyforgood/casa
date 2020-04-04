class VolunteersController < ApplicationController
  before_action :authenticate_user!

  def index
    @case_contact = CaseContact.new
  end

  def edit
  end
end
