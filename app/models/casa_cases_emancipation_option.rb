class CasaCasesEmancipationOption < ApplicationRecord
  belongs_to :casa_case
  belongs_to :emancipation_option
end

# == Schema Information
#
# Table name: casa_cases_emancipation_options
#
#  id                     :bigint           not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  casa_case_id           :bigint           not null
#  emancipation_option_id :bigint           not null
#
# Indexes
#
#  index_casa_cases_emancipation_options_on_casa_case_id      (casa_case_id)
#  index_case_emancipation_options_on_emancipation_option_id  (emancipation_option_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (emancipation_option_id => emancipation_options.id)
#
