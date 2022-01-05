class FeatureFlag < ApplicationRecord
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
