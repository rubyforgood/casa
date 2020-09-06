require "faker"

CaseContact.delete_all
SupervisorVolunteer.delete_all
CaseAssignment.delete_all
CasaCase.delete_all
User.delete_all
CasaOrg.delete_all
AllCasaAdmin.delete_all

pg_casa = CasaOrg.first_or_create!(name: "Prince George CASA")

# number casa cases to generate
CASA_CASE_COUNT = 2

SEED_PASSWORD = "123456"

AllCasaAdmin.first_or_create!(
  email: "allcasaadmin@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

# seed users for all types [volunteer supervisor casa_admin]
# volunteer users
volunteer = Volunteer.first_or_create!(
  casa_org: pg_casa,
  # display_name intentionally left blank
  email: "volunteer1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

# supervisor user
supervisor = Supervisor.first_or_create!(
  casa_org_id: pg_casa.id,
  display_name: "Gloria O'Malley",
  email: "supervisor1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

# Will fail silently if supervisor-volunteer record already exists.
SupervisorVolunteer.create(supervisor: supervisor, volunteer: volunteer)

# casa_admin user
admin = CasaAdmin.first_or_create!(
  casa_org_id: pg_casa.id,
  display_name: Faker::Name.name,
  email: "casa_admin1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

def case_number_generator
  # CINA-YY-XXXX
  years = ((DateTime.now.year - 20)..DateTime.now.year).to_a
  yy = years.sample.to_s[2..3]
  sequence_num = rand(1000..9999)
  "CINA-#{yy}-#{sequence_num}"
end

# generate more CasaCases, add data, assign case to volunteer
unless CasaCase.count > 0
  CASA_CASE_COUNT.times do |index|
    new_casa_case = CasaCase.create!(
      casa_org_id: pg_casa.id,
      case_number: case_number_generator,
      transition_aged_youth: index % 2 == 0,
    )
    CaseAssignment.create!(
      casa_case: new_casa_case,
      volunteer: volunteer
    )
  end
end

# create CaseContact and associate with CasaCase, volunteer creator and include data
CaseContact.first_or_create!(
  casa_case: CasaCase.first,
  creator: volunteer,
  duration_minutes: 30,
  occurred_at: 2.months.ago,
  contact_types: CaseContact::CONTACT_TYPES.sample(3),
  medium_type: CaseContact::CONTACT_MEDIUMS.sample,
  miles_driven: 5,
  want_driving_reimbursement: false,
  contact_made: true
)

############################
## Other CASA Organization #
############################
other_casa = CasaOrg.first_or_create!(name: "Other CASA org")

CasaAdmin.where(
  email: "other_casa_admin@example.com",
).first_or_create!(
  casa_org: other_casa,
  display_name: "Other Admin",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

Supervisor.where(
  email: "other.supervisor@example.com",
).first_or_create!(
  casa_org: other_casa,
  display_name: "Other Supervisor",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

Volunteer.where(
  email: "other.volunteer@example.com",
).first_or_create!(
  casa_org: other_casa,
  display_name: "Other Volunteer",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
