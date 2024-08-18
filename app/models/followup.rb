class Followup < ApplicationRecord
  belongs_to :followupable, polymorphic: true, optional: true # TODO polymorph: remove optional after data is safely migrated
  belongs_to :creator, class_name: "User"

  before_save :maintain_backward_compatibility

  enum status: {requested: 0, resolved: 1}

  validate :uniqueness_of_requested

  def self.in_organization(casa_org)
    # if other followupable_types are added this will need exapansion
    joins("LEFT JOIN case_contacts ON case_contacts.id = followups.followupable_id AND followups.followupable_type = 'CaseContact'")
      .joins("LEFT JOIN casa_cases ON casa_cases.id = case_contacts.casa_case_id")
      .where(casa_cases: { casa_org_id: casa_org.id })
  end

  def uniqueness_of_requested
    return if resolved?
    return if existing_requested_followup?

    errors.add(:base, "Only 1 Followup can be in requested status.")
  end

  # Must add to this if we add more followupable options
  def associated_casa_case
    case followupable
    when CaseContact
      followupable.casa_case
    else
      nil
    end
  end

  private

  def existing_requested_followup?
    Followup.where(status: :requested, followupable_id: self.followupable_id).count == 0
  end

  def maintain_backward_compatibility
    if followupable.is_a?(CaseContact)
      self.case_contact_id = followupable.id
    else
      self.case_contact_id = nil
    end
  end
end

# == Schema Information
#
# Table name: followups
#
#  id                :bigint           not null, primary key
#  followupable_type :string
#  note              :text
#  status            :integer          default("requested")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  case_contact_id   :bigint
#  creator_id        :bigint
#  followupable_id   :bigint
#
# Indexes
#
#  index_followups_on_case_contact_id                        (case_contact_id)
#  index_followups_on_creator_id                             (creator_id)
#  index_followups_on_followupable_type_and_followupable_id  (followupable_type,followupable_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
