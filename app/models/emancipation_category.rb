class EmancipationCategory < ApplicationRecord
  has_many :emancipation_options, -> { where mutually_exclusive: true }
  has_one  :emancipation_options, -> { where mutually_exclusive: false }
  validates :name, presence: true
  validates :mutually_exclusive, presence: true 
end

# == Schema Information
#
# Table name: emancipation_categories
#
#  id                 :bigint           not null, primary key
#  mutually_exclusive :boolean          not null
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_emancipation_categories_on_name  (name) UNIQUE
#
