class ContactType < ApplicationRecord
  belongs_to :contact_type_group
end

# == Schema Information
#
# Table name: contact_types
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  contact_type_group_id :bigint           not null
#
# Indexes
#
#  index_contact_types_on_contact_type_group_id  (contact_type_group_id)
#
