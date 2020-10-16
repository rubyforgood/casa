require "faker"

CaseContact.delete_all
SupervisorVolunteer.delete_all
CaseAssignment.delete_all
CasaCase.delete_all
User.delete_all
CasaOrg.delete_all
AllCasaAdmin.delete_all

pg_casa = CasaOrg.create(name: "Prince George CASA")

ContactTypeGroup.create(casa_org: pg_casa, name: "CASA").tap do |group|
  ContactType.create(contact_type_group: group, name: "Youth")
  ContactType.create(contact_type_group: group, name: "Supervisor")
end

#
# Config
#
# number of volunteer users and casa cases to generate
volunteer_user_count = 100
casa_case_count = 150
supervisor_count = 5
seed_password = "123456"
casa_admin_count = 3

AllCasaAdmin.first_or_create(
  email: "allcasaadmin@example.com",
  password: seed_password,
  password_confirmation: seed_password
)

volunteer_users = []

# generate volunteer users via Faker gem
volunteer_user_count.times do |index|
  volunteer_email = "volunteer#{index + 1}@example.com"
  volunteer_user = Volunteer.where(email: volunteer_email).first_or_create!(
    casa_org: pg_casa,
    display_name: Faker::Name.unique.name,
    password: seed_password,
    password_confirmation: seed_password,
    active: index % 30 != 0 # creates an inactive user every 30 times this is run
  )
  volunteer_users.push(volunteer_user)
end

# generate more supervisor users via Faker gem
supervisor_users = []
supervisor_count.times do |index|
  supervisor_email = "supervisor#{index + 1}@example.com"
  new_supervisor_user = Supervisor.where(email: supervisor_email).first_or_create!(
    casa_org_id: pg_casa.id,
    display_name: Faker::Name.unique.name,
    password: seed_password,
    password_confirmation: seed_password
  )
  supervisor_users.push(new_supervisor_user)
end

# casa_admin users
casa_admin_count.times do |index|
  casa_admin_email = "casa_admin#{index + 1}@example.com"
  CasaAdmin.where(email: casa_admin_email).first_or_create!(
    casa_org_id: pg_casa.id,
    display_name: Faker::Name.unique.name,
    password: seed_password,
    password_confirmation: seed_password
  )
end

def case_number_generator
  # CINA-YY-XXXX
  years = ((DateTime.now.year - 20)..DateTime.now.year).to_a
  yy = years.sample.to_s[2..3]
  sequence_num = rand(1000..9999)
  "CINA-#{yy}-#{sequence_num}"
end

# generate more CasaCases, add data, assign case to volunteer
casa_cases = []
years = ((DateTime.now.year - 20)..DateTime.now.year).to_a
yy = years.sample.to_s[2..3]
casa_case_count.times do |index|
  new_casa_case = CasaCase.where(case_number: "CINA-#{yy}-#{1001 + index}").first_or_create!(
    casa_org_id: pg_casa.id,
    transition_aged_youth: false
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
  SupervisorVolunteer.create(supervisor: supervisor_assigned, volunteer: volunteer_user)
end

def even_odds
  rand(100) > 50
end

# create CaseContact and associate with CasaCase, volunteer creator and include data
vols = Volunteer.all
vols.map do |vol|
  vol.case_assignments.map { |case_assignment|
    casa_case = case_assignment.casa_case
    likely_durations = [15, 30, 60, 75, 4 * 60, 6 * 60]
    (1..24).map { |months_ago|
      if even_odds
        occurred_at = DateTime.now - months_ago.months
        miles_driven = even_odds ? rand(200) : 0
        want_driving_reimbursement = miles_driven ? even_odds : false
        CaseContact.create(
          casa_case: casa_case,
          creator: vol,
          duration_minutes:
              likely_durations.sample,
          occurred_at: occurred_at,
          contact_types: ContactType.take(2),
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
other_casa = CasaOrg.where(name: "Other CASA org").first_or_create!

CasaAdmin.where(email: "other_casa_admin@example.com").first_or_create!(
  casa_org: other_casa,
  display_name: "Other Admin",
  password: seed_password,
  password_confirmation: seed_password
)

Supervisor.where(email: "other.supervisor@example.com").first_or_create!(
  casa_org: other_casa,
  display_name: "Other Supervisor",
  password: seed_password,
  password_confirmation: seed_password
)

Volunteer.where(email: "other.volunteer@example.com").first_or_create!(
  casa_org: other_casa,
  display_name: "Other Volunteer",
  password: seed_password,
  password_confirmation: seed_password
)
