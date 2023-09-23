class LearningHourTopic < ApplicationRecord
  belongs_to :casa_org
  validates :name, presence: true, uniqueness: {scope: %i[casa_org], case_sensitive: false}
  before_validation :strip_name
  scope :for_organization, ->(org) { where(casa_org: org).order(:name) }

  private

  def strip_name
    self.name = name.strip if name
  end
end

# == Schema Information
#
# Table name: learning_hour_topics
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  position    :integer          default(1)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_learning_hour_topics_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
