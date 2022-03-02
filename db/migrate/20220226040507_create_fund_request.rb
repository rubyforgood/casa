class CreateFundRequest < ActiveRecord::Migration[6.1]
  def change
    create_table :fund_requests do |t|
      t.text :submitter_email
      t.text :youth_name
      t.text :payment_amount
      t.text :deadline
      t.text :request_purpose
      t.text :payee_name
      t.text :requested_by_and_relationship
      t.text :other_funding_source_sought
      t.text :impact
      t.text :extra_information
      t.text :timestamps
    end
  end
end
