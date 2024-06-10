class Banner < ApplicationRecord
  belongs_to :casa_org
  belongs_to :user
  has_rich_text :content

  scope :active, -> { where(active: true) }

  validates_presence_of :name
  validates_presence_of :content
  validate :only_one_banner_is_active_per_organization
  validates_comparison_of :expires_at, greater_than: Time.current, message: "must take place in the future (after %{value} )", allow_blank: true

  def expired?
    expired = expires_at && Time.current > expires_at
    update(active: false) if active && expired
  end

  # `expires_at` is stored in the database as UTC, but timezone information will be stripped before displaying on frontend
  # so this method converts the time to the user's timezone before displaying it
  def expires_at_in_time_zone(timezone)
    expires_at&.in_time_zone(timezone)
  end

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
#  expires_at  :datetime
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
