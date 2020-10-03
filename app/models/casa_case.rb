class CasaCase < ApplicationRecord
  has_paper_trail

  has_many :case_assignments
  has_many(:volunteers, through: :case_assignments, source: :volunteer, class_name: "User")
  has_many :case_contacts
  validates :case_number, uniqueness: {case_sensitive: false}, presence: true
  belongs_to :casa_org

  has_many :casa_case_contact_types
  has_many :contact_types, through: :casa_case_contact_types, source: :contact_type
  accepts_nested_attributes_for :casa_case_contact_types

  scope :ordered, -> { order(updated_at: :desc) }
  scope :actively_assigned_to, ->(volunteer) {
    joins(:case_assignments).where(
      case_assignments: {volunteer: volunteer, is_active: true}
    )
  }
  scope :actively_assigned_excluding_volunteer, ->(volunteer) {
    joins(:case_assignments)
      .where(case_assignments: {is_active: true})
      .where.not(case_assignments: {volunteer: volunteer})
      .order(:case_number)
  }
  scope :not_assigned, ->(casa_org) {
    where(casa_org_id: casa_org.id)
      .left_outer_joins(:case_assignments)
      .where(case_assignments: {id: nil})
      .order(:case_number)
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

  def has_transitioned?
    transition_aged_youth
  end

  def update_cleaning_contact_types(args)
    transaction do
      casa_case_contact_types.destroy_all
      update(args)
    end
  end
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                     :bigint           not null, primary key
#  birth_month_year_youth :datetime
#  case_number            :string           not null
#  court_report_submitted :boolean          default(FALSE), not null
#  transition_aged_youth  :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  casa_org_id            :bigint           not null
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
