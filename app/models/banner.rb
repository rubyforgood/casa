class Banner < ApplicationRecord
  belongs_to :casa_org
  belongs_to :user
  has_rich_text :content

  scope :active, -> { where(active: true) }

  validates_presence_of :name

  private
end

# == Schema Information
#
# Table name: banners
#
#  id          :bigint           not null, primary key
#  active      :boolean          default(FALSE)
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_banners_on_casa_org_id  (casa_org_id)
#  index_banners_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#  fk_rails_...  (user_id => users.id)
#
