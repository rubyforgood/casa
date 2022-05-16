class CasaCaseContactType < ApplicationRecord
  belongs_to :casa_case
  belongs_to :contact_type

  validates :casa_case_id, uniqueness: {scope: :contact_type_id}
end

# == Schema Information
#
# Table name: casa_case_contact_types
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  casa_case_id    :bigint           not null
#  contact_type_id :bigint           not null
#
# Indexes
#
#  index_casa_case_contact_types_on_casa_case_id     (casa_case_id)
#  index_casa_case_contact_types_on_contact_type_id  (contact_type_id)
#
