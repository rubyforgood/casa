class AdditionalExpensePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin, Supervisor
        scope.joins(:contact_creator).where(contact_creator: {casa_org: user.casa_org})
      when Volunteer
        scope.where(case_contact: user.case_contacts)
      else
        scope.none
      end
    end
  end

  def create?
    case user
    when Volunteer
      user.case_contacts.exists?(record.case_contact_id)
    when CasaAdmin, Supervisor
      same_org?
    else
      false
    end
  end

  alias_method :destroy?, :create?

  private

  def same_org?
    record_org = record.casa_org || record.contact_creator_casa_org
    user&.casa_org == record_org
  end
end
