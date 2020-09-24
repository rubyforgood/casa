class CasaCaseContactType < ApplicationRecord
  belongs_to :case_contact, class_name: "CaseContact"
  belongs_to :contact_type, class_name: "ContactType"
end

# == Schema Information
#
# Table name: casa_case_contact_types
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  casa_case_id    :bigint           not null
#  case_contact_id :bigint           not null
#
# Indexes
#
#  index_casa_case_contact_types_on_casa_case_id     (casa_case_id)
#  index_casa_case_contact_types_on_case_contact_id  (case_contact_id)
#
