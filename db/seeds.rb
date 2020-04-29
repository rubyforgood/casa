require 'faker'

CaseContact.delete_all
SupervisorVolunteer.delete_all
CaseAssignment.delete_all
CasaCase.delete_all
User.delete_all
CasaOrg.delete_all
AllCasaAdmin.delete_all

pg_casa = CasaOrg.create(name: 'Prince George CASA')
other_casa = CasaOrg.create(name: 'Other CASA org')

# number of volunteer users and casa cases to generate
VOLUNTEER_USER_COUNT = 100
CASA_CASE_COUNT = 150
SUPERVISOR_COUNT = 5

# seed users for all 'roles' [volunteer supervisor casa_admin inactive]
# volunteer users
volunteer_user_1 = User.create(
  casa_org: pg_casa,
  # display_name intentionally left blank
  email: 'volunteer1@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :volunteer
)
volunteer_user_2 = User.create(
  casa_org: pg_casa,
  display_name: Faker::Name.name,
  email: 'volunteer2@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :volunteer
)
volunteer_user_3 = User.create(
  casa_org: pg_casa,
  display_name: 'Myra Shanjar',
  email: 'volunteer3@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :volunteer
)
volunteer_users = [ volunteer_user_1, volunteer_user_2, volunteer_user_3 ]

# generate volunteer users via Faker gem
VOLUNTEER_USER_COUNT.times do
  volunteer_name = Faker::Name.name
  volunteer_email_name = volunteer_name.downcase.sub(' ', '')
  volunteer_user = User.create(
    casa_org: pg_casa,
    display_name:  volunteer_name,
    # Generates an RFC 2606 compliant fake email, which means it will never deliver successfully
    email: Faker::Internet.safe_email(name: volunteer_email_name),
    password: '123456',
    password_confirmation: '123456',
    role: :volunteer
  )
  volunteer_users.push(volunteer_user)
end

# supervisor users
supervisor_user_1 = User.create(
  casa_org_id: pg_casa.id,
  display_name: 'Gloria O\'Malley',
  email: 'supervisor1@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :supervisor
)

# generate more supervisor users via Faker gem
supervisor_users = [ supervisor_user_1 ]
SUPERVISOR_COUNT.times do | index |
  supervisor_name = Faker::Name.unique.name
  supervisor_email_name = supervisor_name.downcase.sub(' ', '')
  new_supervisor_user = User.create(
    casa_org_id: pg_casa.id,
    display_name: supervisor_name,
    email: Faker::Internet.safe_email(name: supervisor_email_name),
    password: '123456',
    password_confirmation: '123456',
    role: :supervisor
  )
  supervisor_users.push(new_supervisor_user)
end

# casa_admin users
casa_admin_user_1 = User.create(
  casa_org_id: pg_casa.id,
  display_name: '1;DROP TABLE users',
  email: 'casa_admin1@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :casa_admin
)
casa_admin_user_2 = User.create(
  casa_org_id: pg_casa.id,
  display_name: 'Uche O\'Donnel',
  email: 'casa_admin2@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :casa_admin
)

# inactive users
inactive_user_1 = User.create(
  casa_org_id: pg_casa.id,
  display_name: 'undefined Kent II',
  email: 'inactive1@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :inactive
)
inactive_user_2 = User.create(
  casa_org_id: pg_casa.id,
  display_name: 'בְּרֵאשִׁית, בָּרָא אֱלֹהִים, אֵת הַשָּׁמַיִם, וְאֵת הָאָרֶץ',
  email: 'inactive2@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :inactive
)

# generate more CasaCases, add data, assign case to volunteer
casa_cases = []
CASA_CASE_COUNT.times do | index |
  new_casa_case = CasaCase.create(
    case_number: Faker::Number.unique.number(digits: 6), # TODO: verify what case numbers look like
    transition_aged_youth: index % 3 == 0 # true for a third of cases
  )
  volunteer_assigned = volunteer_users[index % volunteer_users.length]
  new_case_assignment = CaseAssignment.create(
    casa_case: new_casa_case,
    volunteer: volunteer_assigned,
  )
  casa_cases.push(new_casa_case)
end

# associate volunteers with supervisors
volunteer_users.each_with_index do | volunteer_user, index |
  supervisor_assigned = supervisor_users[index % supervisor_users.length ]
  SupervisorVolunteer.create(
    [
      { supervisor_id: supervisor_assigned.id, volunteer_id: volunteer_user.id }
    ]
  )
end

# create CaseContact and associate with CasaCase, volunteer creator and include data
case_1 = casa_cases[0]
case_1_volunteer = case_1.volunteers[0]
CaseContact.create(
  [
    { casa_case_id: case_1.id, creator_id: case_1_volunteer.id, duration_minutes: 15, occurred_at: DateTime.new(2020, 2, 3, 4, 5, 6), contact_type: :school },
    { casa_case_id: case_1.id, creator_id: case_1_volunteer.id, duration_minutes: 15, occurred_at: DateTime.new(2020, 2, 10), contact_type: :school }
  ]
)
