class FeatureFlag < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: feature_flags
#
#  id         :bigint           not null, primary key
#  enabled    :boolean          default(FALSE), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_name  (name) UNIQUE
#
