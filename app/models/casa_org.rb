class CasaOrg < ApplicationRecord
  CASA_DEFAULT_COURT_REPORT = File.new(Rails.root.join("app", "documents", "templates", "default_report_template.docx"), "r")
  CASA_DEFAULT_LOGO = Rails.root.join("public", "logo.jpeg")

  before_create :set_slug

  has_paper_trail
  validates :name, presence: true, uniqueness: true

  has_many :users, dependent: :destroy
  has_many :casa_cases, dependent: :destroy
  has_many :contact_type_groups, dependent: :destroy
  has_many :hearing_types, dependent: :destroy
  has_many :mileage_rates, dependent: :destroy
  has_many :case_assignments, through: :users, source: :casa_cases
  has_one_attached :logo
  has_one_attached :court_report_template

  def casa_admins
    CasaAdmin.in_organization(self)
  end

  def supervisors
    Supervisor.in_organization(self)
  end

  def volunteers
    Volunteer.in_organization(self)
  end

  def case_contacts
    CaseContact.where(
      casa_case_id: CasaCase.where(casa_org_id: id)
    )
  end

  def org_logo
    if logo.attached?
      Rails.application.routes.url_helpers.rails_blob_path(logo, only_path: true)
    else
      CASA_DEFAULT_LOGO
    end
  end

  def open_org_court_report_template(&block)
    if court_report_template.attached?
      court_report_template.open(&block)
    else
      yield CASA_DEFAULT_COURT_REPORT
    end
  end

  def set_slug
    self.slug = name.parameterize
  end

  # def to_param
  #   id
  #   # slug # TODO use slug eventually for routes
  # end
end

# == Schema Information
#
# Table name: casa_orgs
#
#  id                         :bigint           not null, primary key
#  address                    :string
#  display_name               :string
#  footer_links               :string           default([]), is an Array
#  name                       :string           not null
#  show_driving_reimbursement :boolean          default(TRUE)
#  slug                       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_casa_orgs_on_slug  (slug) UNIQUE
#
