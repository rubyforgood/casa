class ContactTypeGroup < ApplicationRecord
  has_paper_trail
  belongs_to :casa_org
  has_many :contact_types

  validates :name, presence: true, uniqueness: {scope: :casa_org_id}

  scope :for_organization, ->(org) { where(casa_org: org) }
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
