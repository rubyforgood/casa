class EmancipationChecklistsController < ApplicationController
  def show
    authorize :application, :see_emancipation_checklist?
  end
end
