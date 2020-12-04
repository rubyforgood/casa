class EmancipationCategory < ApplicationRecord
  has_many :emancipation_options
  validates :name, presence: true
  validates :mutually_exclusive, inclusion: {in: [true, false]}

  def add_option(option_name)
    emancipation_options.create(name: option_name)
  end
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
