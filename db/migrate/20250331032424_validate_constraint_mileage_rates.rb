class ValidateConstraintMileageRates < ActiveRecord::Migration[7.2]
  def up
    ActiveRecord::Base.connection.execute(Arel.sql("ALTER TABLE mileage_rates VALIDATE CONSTRAINT fk_rails_3dad81992f;"))
  end

  def down
    # cannot un-validate a constraint
  end
end
