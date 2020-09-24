class CreateCasaCaseContactType < ApplicationRecord
  belongs_to :case_contact, class_name: "CaseContact"
  belongs_to :contact_type, class_name: "ContactType"
end
