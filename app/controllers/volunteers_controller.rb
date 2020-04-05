class VolunteersController < ApplicationController
  before_action :authenticate_user!

  def index
    @case_contact = CaseContact.new
  end

  def new
    @volunteer = User.new(role: :volunteer)
  end

  def edit
  end
end
