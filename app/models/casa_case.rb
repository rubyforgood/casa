class CasaCase < ApplicationRecord
  has_paper_trail

  has_many :case_assignments
  has_many(:volunteers, through: :case_assignments, source: :volunteer, class_name: "User")
  has_many :case_contacts
  validates :case_number, uniqueness: {case_sensitive: false}, presence: true
  belongs_to :casa_org

  scope :ordered, -> { order(updated_at: :desc) }
  scope :actively_assigned_to, ->(volunteer) {
    joins(:case_assignments).where(
      case_assignments: {volunteer: volunteer, is_active: true}
    )
  }

  def self.available_for_volunteer(volunteer)
    ids = connection.select_values(%{
      SELECT casa_cases.id
      FROM casa_cases
      WHERE id NOT IN (SELECT ca.casa_case_id
                      FROM case_assignments ca
                      WHERE ca.volunteer_id = #{volunteer.id}
                      GROUP BY ca.casa_case_id)
      GROUP BY casa_cases.id;
    })
    where(id: ids, casa_org: volunteer.casa_org)
      .order(:case_number)
  end
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                    :bigint           not null, primary key
#  case_number           :string           not null
#  transition_aged_youth :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  casa_org_id           :bigint           not null
#
# Indexes
#
#  index_casa_cases_on_casa_org_id  (casa_org_id)
#  index_casa_cases_on_case_number  (case_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
