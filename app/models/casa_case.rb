class CasaCase < ApplicationRecord # rubocop:todo Style/Documentation
  has_paper_trail
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                    :bigint           not null, primary key
#  case_number           :string           not null
#  teen_program_eligible :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_casa_cases_on_case_number  (case_number) UNIQUE
#
