class Language < ApplicationRecord
  belongs_to :casa_org
  has_many :user_languages
  has_many :users, through: :user_languages
  before_validation :strip_name

  validates :name, presence: true, uniqueness: {scope: :casa_org, case_sensitive: false}

  private

  def strip_name
    self.name = name.strip if name
  end
end

# == Schema Information
#
# Table name: languages
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  casa_org_id :bigint           not null
#
# Indexes
#
#  index_languages_on_casa_org_id  (casa_org_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
