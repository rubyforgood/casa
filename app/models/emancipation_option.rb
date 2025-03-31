class EmancipationOption < ApplicationRecord
  belongs_to :emancipation_category
  has_many :casa_cases_emancipation_options, dependent: :destroy
  has_many :casa_cases, through: :casa_cases_emancipation_options

  validates :name, presence: true, uniqueness: {scope: :emancipation_category_id}

  scope :category_options, ->(emancipation_category_id) {
    where(emancipation_category_id: emancipation_category_id)
  }

  scope :options_with_category_and_case, ->(emancipation_category_id, casa_case_id) {
    joins(:casa_cases)
      .where(casa_cases_emancipation_options: {casa_case_id: casa_case_id})
      .where(emancipation_category_id: emancipation_category_id)
  }
end

# == Schema Information
#
# Table name: emancipation_options
#
#  id                       :bigint           not null, primary key
#  name                     :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  emancipation_category_id :bigint           not null
#
# Indexes
#
#  index_emancipation_options_on_emancipation_category_id_and_name  (emancipation_category_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (emancipation_category_id => emancipation_categories.id)
#
