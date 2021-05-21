class ContactType < ApplicationRecord
  has_paper_trail
  belongs_to :contact_type_group

  validates :name, presence: true, uniqueness: {scope: :contact_type_group_id,
                                                message: "should be unique per contact type group"}

  scope :for_organization, ->(org) {
    joins(:contact_type_group)
      .where(contact_type_groups: {casa_org: org})
  }
end

# == Schema Information
#
# Table name: contact_types
#
#  id                    :bigint           not null, primary key
#  active                :boolean          default(TRUE)
#  name                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contact_type_group_id :bigint           not null
#
# Indexes
#
#  index_contact_types_on_contact_type_group_id  (contact_type_group_id)
#
