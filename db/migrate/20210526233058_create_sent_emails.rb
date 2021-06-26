class CreateSentEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :sent_emails do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.references :casa_org, null: false, foreign_key: true
      t.string :mailer_type
      t.string :category
      t.string :sent_address

      t.timestamps
    end
  end
end
