class AddReferenceLearningHourTypes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # add_reference :learning_hours, :learning_hour_type, validate: false, index: {algorithm: :concurrently}
    add_reference :learning_hours, :learning_hour_type, index: {algorithm: :concurrently}
  end
end
