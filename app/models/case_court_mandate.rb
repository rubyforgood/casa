class CaseCourtMandate < ApplicationRecord
  belongs_to :casa_case
end

# == Schema Information
#
# Table name: case_court_mandates
#
#  id           :bigint           not null, primary key
#  mandate_text :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
