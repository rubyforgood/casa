class CaseGroup < ApplicationRecord
  belongs_to :casa_org
  has_many :case_group_memberships, dependent: :destroy
  has_many :casa_cases, through: :case_group_memberships
  before_validation :strip_name

  validates :case_group_memberships, presence: true

  validates :name, presence: true, uniqueness: {scope: :casa_org, case_sensitive: false}

  private

  def strip_name
    self.name = name.strip if name
  end
end

# == Schema Information
#
# Table name: case_groups
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_case_groups_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
