class ValidateConstraintPlacements < ActiveRecord::Migration[7.2]
  def up
    ActiveRecord::Base.connection.execute(Arel.sql("ALTER TABLE placements VALIDATE CONSTRAINT fk_rails_65aeeb5669;"))
  end

  def down
    # cannot un-validate a constraint
  end
end
