class FollowupPolicy < ApplicationPolicy
  # With a Followup record: admins and supervisors may set a reminder on any case contact in their org,
  # volunteers only on case contacts they created. With the class (no record): role check only.
  def create?
    return admin_or_supervisor_or_volunteer? unless record.is_a?(Followup)

    case_contact = record.case_contact
    return false unless case_contact && user&.casa_org_id.present? && user.casa_org_id == case_contact.creator&.casa_org_id

    admin_or_supervisor? || (is_volunteer? && case_contact.creator_id == user.id)
  end

  def resolve?
    admin_or_supervisor_or_volunteer_same_org?
  end
end
