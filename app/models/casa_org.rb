class CasaOrg < ApplicationRecord
  # NOTE: location of the default report template
  CASA_DEFAULT_COURT_REPORT = File.new(Rails.root.join("app", "documents", "templates", "default_report_template.docx"), "r")
  CASA_DEFAULT_LOGO = Rails.root.join("public", "logo.jpeg")

  scope :with_logo, -> { joins(:logo_attachment) }

  before_create :set_slug
  before_update :sanitize_svg
  before_save :normalize_phone_number

  validates :name, presence: true, uniqueness: true
  validates_with CasaOrgValidator
  validate :validate_twilio_credentials, if: -> { twilio_enabled || twilio_account_sid.present? || twilio_api_key_sid.present? || twilio_api_key_secret.present? }, on: :update

  has_many :users, dependent: :destroy
  has_many :casa_cases, dependent: :destroy
  has_many :contact_type_groups, dependent: :destroy
  has_many :hearing_types, dependent: :destroy
  has_many :mileage_rates, dependent: :destroy
  has_many :case_assignments, through: :users, source: :casa_cases
  has_many :languages, dependent: :destroy
  has_many :placements, through: :casa_cases
  has_many :banners, dependent: :destroy
  has_many :learning_hour_types, dependent: :destroy
  has_many :learning_hour_topics, dependent: :destroy
  has_many :case_groups, dependent: :destroy
  has_many :contact_topics
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
    CaseContact.includes(:creator).where(
      casa_case_id: CasaCase.where(casa_org_id: id)
    ).or(
      CaseContact.includes(:creator).where(
        casa_case_id: nil, creator: {casa_org: self}
      )
    )
  end

  def followups
    Followup.in_organization(self)
  end

  def case_contacts_count
    case_contacts.count
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

  def user_count
    users.count
  end

  def set_slug
    self.slug = name.parameterize
  end

  def generate_defaults
    ActiveRecord::Base.transaction do
      ContactTopic.generate_for_org!(self)
      ContactTypeGroup.generate_for_org!(self)
      HearingType.generate_for_org!(self)
    end
  end

  def contact_types_by_group
    contact_type_groups.joins(:contact_types).where(contact_types: {active: true}).alphabetically.uniq
  end

  # Returns contact types that are active and tied to the CasaOrg as a an array of hashes that can be used by the multiple select component
  # @return [ActiveRecord::Relation<ContactType>]
  def contact_types
    ContactType.joins(:contact_type_group).where(active: true, contact_type_group: {casa_org: self}).order(:name)
  end

  # Given a specific date, returns the active mileage rate.
  # If more than one mileage rate is active for a given date, assumes the rate for the most recent date takes precedence.
  # For instance, given two mileage rates that are active, one set on January 1, 1970 and one set on January 3, 1970:
  # then the active rate for the given date of January 5, 1970 would be the January 3 rate.
  # If no rates are active for the given date, will return nil.
  # @param date [Date]
  # @return [BigDecimal, nil]
  def mileage_rate_for_given_date(date)
    mileage_rates.where(is_active: true, effective_date: ..date).order(effective_date: :desc).first&.amount
  end

  def has_alternate_active_banner?(current_banner_id)
    banners.where(active: true).where.not(id: current_banner_id).exists?
  end

  private

  def sanitize_svg
    if attachment_changes["logo"]
      file = attachment_changes["logo"].attachable
      sanitized_file = SvgSanitizerService.sanitize(file)
      logo.unfurl(sanitized_file)
    end
  end

  # def to_param
  #   id
  #   # slug # TODO use slug eventually for routes
  # end

  def validate_twilio_credentials
    client = Twilio::REST::Client.new(twilio_api_key_sid, twilio_api_key_secret, twilio_account_sid)
    begin
      client.messages.list(limit: 1)
    rescue Twilio::REST::RestError
      errors.add(:base, "Your Twilio credentials are incorrect, kindly check and try again.")
    end
  end

  def normalize_phone_number
    if twilio_phone_number&.length == 10
      self.twilio_phone_number = "+1#{twilio_phone_number}"
    end
  end
end

# == Schema Information
#
# Table name: casa_orgs
#
#  id                          :bigint           not null, primary key
#  additional_expenses_enabled :boolean          default(FALSE)
#  address                     :string
#  display_name                :string
#  footer_links                :string           default([]), is an Array
#  learning_topic_active       :boolean          default(FALSE)
#  name                        :string           not null
#  show_driving_reimbursement  :boolean          default(TRUE)
#  show_fund_request           :boolean          default(FALSE)
#  slug                        :string
#  twilio_account_sid          :string
#  twilio_api_key_secret       :string
#  twilio_api_key_sid          :string
#  twilio_enabled              :boolean          default(FALSE)
#  twilio_phone_number         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_casa_orgs_on_slug  (slug) UNIQUE
#
