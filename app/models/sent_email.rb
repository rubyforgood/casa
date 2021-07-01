class SentEmail < ApplicationRecord
  belongs_to :user
  belongs_to :casa_org

  validates :mailer_type, presence: true
  validates :category, presence: true
  validates :sent_address, presence: true

  scope :for_organization, ->(org) { where(casa_org: org) }
end

# == Schema Information
#
# Table name: sent_emails
#
#  id           :bigint           not null, primary key
#  category     :string
#  mailer_type  :string
#  sent_address :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_org_id  :bigint           not null
#  user_id      :bigint
#
# Indexes
#
#  index_sent_emails_on_casa_org_id  (casa_org_id)
#  index_sent_emails_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#  fk_rails_...  (user_id => users.id)
#
