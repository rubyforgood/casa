module AllCasaAdmins
  module CasaOrgsHelper
    def selected_organization
      # this is in the context of the all casa admin
      # without this, the current_organization gets set to the current admin's org
      @casa_org
    end
  end
end
