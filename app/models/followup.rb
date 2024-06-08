class Followup < ApplicationRecord
  belongs_to :followupable, polymorphic: true, optional: true # TODO polymorph: remove optional after data is safely migrated
  belongs_to :case_contact
  belongs_to :creator, class_name: "User"
  enum status: {requested: 0, resolved: 1}

  validate :uniqueness_of_requested

  def self.in_organization(casa_org)
    Followup.joins(case_contact: :casa_case).where(casa_cases: {casa_org_id: casa_org.id})
  end

  def uniqueness_of_requested
    return if resolved?
    return if existing_requested_followup?

    errors.add(:base, "Only 1 Followup can be in requested status.")
  end

  private

  def existing_requested_followup?
    Followup.where(status: :requested, case_contact: case_contact).count == 0
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
