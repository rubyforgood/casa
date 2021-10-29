class MileageRate < ApplicationRecord
  belongs_to :user

  validates :effective_date,
    :amount,
    :user_id,
    presence: true,
    allow_blank: false
  validates :effective_date, uniqueness: {scope: :is_active}, if: :is_active?
end

# == Schema Information
#
# Table name: mileage_rates
#
#  id             :bigint           not null, primary key
#  amount         :decimal(, )
#  effective_date :date
#  is_active      :boolean          default(TRUE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_mileage_rates_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
