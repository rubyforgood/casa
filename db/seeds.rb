require "faker"

CaseContact.delete_all
SupervisorVolunteer.delete_all
CaseAssignment.delete_all
CasaCase.delete_all
User.delete_all
CasaOrg.delete_all
AllCasaAdmin.delete_all

pg_casa = CasaOrg.create(name: "Prince George CASA")

# number of volunteer users and casa cases to generate
VOLUNTEER_USER_COUNT = 100
CASA_CASE_COUNT = 150
SUPERVISOR_COUNT = 5

SEED_PASSWORD = "123456"

AllCasaAdmin.create(
  email: "allcasaadmin@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
# seed users for all types [volunteer supervisor casa_admin]
# volunteer users
Volunteer.create(
  casa_org: pg_casa,
  # display_name intentionally left blank
  email: "volunteer1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
volunteer_user_2 = Volunteer.create(
  casa_org: pg_casa,
  display_name: Faker::Name.name,
  email: "volunteer2@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
volunteer_user_3 = Volunteer.create(
  casa_org: pg_casa,
  display_name: "Myra Shanjar",
  email: "volunteer3@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
# intentionally leaving volunteer_user_1 out so it will remain unassigned
volunteer_users = [volunteer_user_2, volunteer_user_3]

# generate volunteer users via Faker gem
VOLUNTEER_USER_COUNT.times do
  volunteer_name = Faker::Name.name
  volunteer_email_name = volunteer_name.downcase.sub(" ", "")
  volunteer_user = Volunteer.create(
    casa_org: pg_casa,
    display_name: volunteer_name,
    # Generates an RFC 2606 compliant fake email, which means it will never deliver successfully
    email: Faker::Internet.safe_email(name: volunteer_email_name),
    password: SEED_PASSWORD,
    password_confirmation: SEED_PASSWORD
  )
  volunteer_users.push(volunteer_user)
end

# supervisor users
supervisor_user_1 = Supervisor.create(
  casa_org_id: pg_casa.id,
  display_name: "Gloria O'Malley",
  email: "supervisor1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

# generate more supervisor users via Faker gem
supervisor_users = [supervisor_user_1]
SUPERVISOR_COUNT.times do |index|
  supervisor_name = Faker::Name.unique.name
  supervisor_email_name = supervisor_name.downcase.sub(" ", "")
  new_supervisor_user = Supervisor.create(
    casa_org_id: pg_casa.id,
    display_name: supervisor_name,
    email: Faker::Internet.safe_email(name: supervisor_email_name),
    password: SEED_PASSWORD,
    password_confirmation: SEED_PASSWORD
  )
  supervisor_users.push(new_supervisor_user)
end

# casa_admin users
CasaAdmin.create(
  casa_org_id: pg_casa.id,
  display_name: "1;DROP TABLE users",
  email: "casa_admin1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
CasaAdmin.create(
  casa_org_id: pg_casa.id,
  display_name: "Uche O'Donnel",
  email: "casa_admin2@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
CasaAdmin.create(
  casa_org_id: pg_casa.id,
  display_name: "Zenne Zown",
  email: "casa_admin3@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

# inactive users
Volunteer.create(
  active: false,
  casa_org_id: pg_casa.id,
  display_name: "undefined Kent II",
  email: "inactive1@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
Volunteer.create(
  active: false,
  casa_org_id: pg_casa.id,
  display_name: "בְּרֵאשִׁית, בָּרָא אֱלֹהִים, אֵת הַשָּׁמַיִם, וְאֵת הָאָרֶץ",
  email: "inactive2@example.com",
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

def chance_of_transition_aged
  rand(1..21) > 13
end

# generate more CasaCases, add data, assign case to volunteer
casa_cases = []
CASA_CASE_COUNT.times do |index|
  new_casa_case = CasaCase.create(
    casa_org_id: pg_casa.id,
    case_number: case_number_generator,
    transition_aged_youth: chance_of_transition_aged
  )
  volunteer_assigned = volunteer_users[index % volunteer_users.length]
  CaseAssignment.create(
    casa_case: new_casa_case,
    volunteer: volunteer_assigned
  )
  casa_cases.push(new_casa_case)
end

# associate volunteers with supervisors
volunteer_users.each_with_index do |volunteer_user, index|
  supervisor_assigned = supervisor_users[index % supervisor_users.length]
  SupervisorVolunteer.create(
    [
      {supervisor_id: supervisor_assigned.id, volunteer_id: volunteer_user.id}
    ]
  )
end

def even_odds
  rand(100) > 50
end

# create CaseContact and associate with CasaCase, volunteer creator and include data
vols = Volunteer.all
vols.map do |vol|
  vol.case_assignments.map { |ca|
    cc = ca.casa_case
    likely_durations = [15, 30, 60, 75, 4 * 60, 6 * 60]
    (1..24).map { |months_ago|
      if even_odds
        occurred_at = DateTime.now - months_ago.months
        miles_driven = even_odds ? rand(200) : nil
        want_driving_reimbursement = miles_driven ? even_odds : false
        CaseContact.create(
          casa_case: cc,
          creator: vol,
          duration_minutes:
              likely_durations.sample,
          occurred_at: occurred_at,
          contact_types: CaseContact::CONTACT_TYPES.sample(3),
          medium_type: CaseContact::CONTACT_MEDIUMS.sample,
          miles_driven: miles_driven,
          want_driving_reimbursement: want_driving_reimbursement,
          contact_made: even_odds
        )
      end
    }
  }
end

###########################
# Other CASA Organization #
###########################
other_casa = CasaOrg.create(name: "Other CASA org")

CasaAdmin.create(
  casa_org: other_casa,
  display_name: "Other Admin",
  email: "other_casa_admin@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

Supervisor.create(
  casa_org: other_casa,
  display_name: "Other Supervisor",
  email: "other.supervisor@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)

Volunteer.create(
  casa_org: other_casa,
  display_name: "Other Volunteer",
  email: "other.volunteer@example.com",
  password: SEED_PASSWORD,
  password_confirmation: SEED_PASSWORD
)
