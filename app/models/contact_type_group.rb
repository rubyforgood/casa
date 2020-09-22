class ContactTypeGroup < ApplicationRecord
  belongs_to :casa_org
  has_many :contact_types
end

# == Schema Information
#
# Table name: contact_type_groups
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_contact_type_groups_on_casa_org_id  (casa_org_id)
#
