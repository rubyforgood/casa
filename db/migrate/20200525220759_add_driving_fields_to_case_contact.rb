class AddDrivingFieldsToCaseContact < ActiveRecord::Migration[6.0]
  def up
    add_column :case_contacts, :miles_driven, :integer, null: true
    add_column :case_contacts, :want_driving_reimbursement, :boolean, default: false
    execute <<-SQL
      ALTER TABLE case_contacts
        ADD CONSTRAINT want_driving_reimbursement_only_when_miles_driven
        CHECK ((miles_driven IS NOT NULL) OR (NOT want_driving_reimbursement));
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE case_contacts
        DROP CONSTRAINT want_driving_reimbursement_only_when_miles_driven
    SQL
    remove_column :case_contacts, :miles_driven, :integer
    remove_column :case_contacts, :want_driving_reimbursement, :boolean
  end
end
