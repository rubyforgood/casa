class CaseContactContactType < ApplicationRecord
  belongs_to :case_contact, class_name: "CaseContact"
  belongs_to :contact_type, class_name: "ContactType"
end

# == Schema Information
#
# Table name: case_contact_contact_types
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  case_contact_id :bigint           not null
#  contact_type_id :bigint           not null
#
# Indexes
#
#  index_case_contact_contact_types_on_case_contact_id  (case_contact_id)
#  index_case_contact_contact_types_on_contact_type_id  (contact_type_id)
#
