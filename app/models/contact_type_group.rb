class ContactTypeGroup < ApplicationRecord
  belongs_to :casa_org
  has_many :contact_types

  validates :name, presence: true, uniqueness: {scope: :casa_org_id}

  scope :for_organization, ->(org) {
    where(casa_org: org)
      .order(:name)
  }

  scope :alphabetically, -> { order(:name) }

  # App-shipped defaults use sentence case (design system), keeping proper nouns/acronyms
  # (CASA, IEP). Org admins can still rename them; only these seeded defaults are cased here.
  DEFAULT_CONTACT_TYPE_GROUPS = {
    CASA: ["Youth", "Supervisor"],
    Family: ["Parent", "Other family", "Sibling", "Grandparent", "Aunt, uncle, or cousin", "Fictive kin"],
    Placement: ["Foster parent", "Caregiver family", "Therapeutic agency worker"],
    "Social services": ["Social worker"],
    Legal: ["Court", "Attorney"],
    Health: ["Medical professional", "Mental health therapist", "Other therapist", "Psychiatric practitioner"],
    Education: ["School", "Guidance counselor", "Teacher", "IEP team"]
  }.freeze

  class << self
    def generate_for_org!(casa_org)
      DEFAULT_CONTACT_TYPE_GROUPS.each do |group_name, type_names|
        group = ContactTypeGroup.find_or_create_by!(
          casa_org: casa_org,
          name: group_name
        )

        type_names.each do |contact_type_name|
          ContactType.find_or_create_by!(
            contact_type_group: group,
            name: contact_type_name
          )
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: contact_type_groups
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE)
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
