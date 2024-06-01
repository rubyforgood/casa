class MileageRate < ApplicationRecord
  self.ignored_columns = [:user_id] # mileage rates are per casa, not per user

  belongs_to :casa_org

  validates :effective_date, presence: true, allow_blank: false
  validates :effective_date, uniqueness: {scope: [:is_active, :casa_org], message: "must not have duplicate active dates"}, if: :is_active?
  validates :effective_date, comparison: {
    greater_than_or_equal_to: "1989-01-01".to_date,
    message: "cannot be prior to 1/1/1989."
  }
  validates :effective_date, comparison: {
    less_than_or_equal_to: -> { 1.year.from_now },
    message: "must not be more than one year in the future."
  }
  validates :amount, presence: true, allow_blank: false
  validates :casa_org, presence: true, allow_blank: false
  scope :for_organization, ->(org) { where(casa_org: org) }
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
#  casa_org_id    :bigint           not null
#
# Indexes
#
#  index_mileage_rates_on_casa_org_id  (casa_org_id)
#  index_mileage_rates_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#  fk_rails_...  (user_id => users.id)
#
