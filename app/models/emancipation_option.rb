class EmancipationOption < ApplicationRecord
  belongs_to :emancipation_category
  has_and_belongs_to_many :casa_cases

  validates :name, presence: true

  def get_category
    return emancipation_category.name
  end
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
#  index_emancipation_options_on_emancipation_category_id           (emancipation_category_id)
#  index_emancipation_options_on_emancipation_category_id_and_name  (emancipation_category_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (emancipation_category_id => emancipation_categories.id)
#
