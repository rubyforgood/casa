class CasaCaseEmancipationCategory < ApplicationRecord
  belongs_to :casa_case
  belongs_to :emancipation_category

  validates :casa_case_id, uniqueness: {scope: :emancipation_category_id}
end

# == Schema Information
#
# Table name: casa_case_emancipation_categories
#
#  id                       :bigint           not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  casa_case_id             :bigint           not null
#  emancipation_category_id :bigint           not null
#
# Indexes
#
#  index_casa_case_emancipation_categories_on_casa_case_id         (casa_case_id)
#  index_case_emancipation_categories_on_emancipation_category_id  (emancipation_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (emancipation_category_id => emancipation_categories.id)
#
