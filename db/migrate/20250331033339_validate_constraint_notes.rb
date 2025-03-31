class ValidateConstraintNotes < ActiveRecord::Migration[7.2]
  def up
    ActiveRecord::Base.connection.execute(Arel.sql("ALTER TABLE notes VALIDATE CONSTRAINT fk_rails_5d4a723a34;"))
  end

  def down
    # cannot un-validate a constraint
  end
end
