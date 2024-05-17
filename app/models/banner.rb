class Banner < ApplicationRecord
  belongs_to :casa_org
  belongs_to :user
  has_rich_text :content

  scope :active, -> { where(active: true) }

  validates_presence_of :name
  validate :only_one_banner_is_active_per_organization

  private

  def only_one_banner_is_active_per_organization
    is_other_banner_active = casa_org.banners.where.not(id: id).any?(&:active?)
    more_than_one_banner_active = is_other_banner_active && active?
    if more_than_one_banner_active
      errors.add(:base, "Only one banner can be active at a time. Mark the other banners as not active before marking this banner as active.")
    end
  end
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
