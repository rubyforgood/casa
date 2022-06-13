class ContactTypeGroup < ApplicationRecord
  belongs_to :casa_org
  has_many :contact_types

  validates :name, presence: true, uniqueness: {scope: :casa_org_id}

  scope :for_organization, ->(org) {
    where(casa_org: org)
      .order(:name)
  }

  scope :alphabetically, -> { order(:name) }

  DEFAULT_CONTACT_TYPE_GROUPS = {
    CASA: ["Youth", "Supervisor"],
    Family: ["Parent", "Other Family", "Sibling", "Grandparent", "Aunt Uncle or Cousin", "Fictive Kin"],
    Placement: ["Foster Parent", "Caregiver Family", "Therapeutic Agency Worker"],
    "Social Services": ["Social Worker"],
    Legal: ["Court", "Attorney"],
    Health: ["Medical Professional", "Mental Health Therapist", "Other Therapist", "Psychiatric Practitioner"],
    Education: ["School", "Guidance Counselor", "Teacher", "IEP Team"]
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
# Indexes
#
#  index_contact_type_groups_on_casa_org_id  (casa_org_id)
#
