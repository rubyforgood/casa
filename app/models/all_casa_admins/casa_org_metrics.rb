module AllCasaAdmins
  class CasaOrgMetrics
    def initialize(casa_org)
      @casa_org = casa_org
    end

    def metrics
      {
        "Number of admins" => @casa_org.casa_admins.count,
        "Number of supervisors" => @casa_org.supervisors.count,
        "Number of active volunteers" => @casa_org.volunteers.active.count,
        "Number of inactive volunteers" => @casa_org.volunteers.inactive.count,
        "Number of active cases" => @casa_org.casa_cases.active.count,
        "Number of inactive cases" => @casa_org.casa_cases.inactive.count,
        "Number of all case contacts including inactives" => @casa_org.case_assignments.count,
        "Number of active supervisor to volunteer assignments" => @casa_org.volunteers.map(&:supervisor).count,
        "Number of active case assignments" => @casa_org.case_assignments.active.count
      }
    end
  end
end
