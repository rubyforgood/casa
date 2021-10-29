class RemoveUserRequiredFromMileageRate < ActiveRecord::Migration[6.1]
  def change
    change_column_null :mileage_rates, :user_id, true
  end
end
