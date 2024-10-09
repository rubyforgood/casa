class ContactTopicAnswerPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user
      when CasaAdmin, Supervisor
        scope.unscoped.joins(:contact_topic).where(contact_topic: {casa_org: user&.casa_org})
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
      user.case_contacts.include?(record.case_contact)
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
