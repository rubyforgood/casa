class CustomLink < ApplicationRecord
  belongs_to :casa_org
  validates :soft_delete, inclusion: [true, false]
  # Validate that the URL is present, has a valid format, and is unique
  validates :url, presence: true,
    format: {with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, message: "must be a valid URL"}
  # Validate that the title is present and has a maximum length of 255 characters
  validates :text, presence: true, length: {maximum: 255}

  scope :active, -> { where(active: true, soft_delete: false) }
end

# == Schema Information
#
# Table name: custom_links
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(TRUE), not null
#  soft_delete :boolean          default(FALSE), not null
#  text        :string
#  url         :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_custom_links_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
