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
  display_name: 'A\'Lelia Bundles',
  email: 'volunteer2@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :volunteer
)
volunteer_user_3 = User.create(
  casa_org: pg_casa,
  display_name: 'בְּרֵאשִׁית, בָּרָא אֱלֹהִים, אֵת הַשָּׁמַיִם, וְאֵת הָאָרֶץ',
  email: 'volunteer3@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :volunteer
)
volunteer_users = [ volunteer_user_1, volunteer_user_2, volunteer_user_3 ]

# generate volunteer users via Faker gem
10.times do
  volunteer_name = Faker::Name.name
  volunteer_email_name = volunteer_name.downcase.sub(' ', '')
  volunteer_user = User.create(
    casa_org: pg_casa,
    display_name:  volunteer_name,
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
supervisor_user_2 = User.create(
  casa_org_id: pg_casa.id,
  display_name: 'Rodolfo Williams',
  email: 'supervisor2@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :supervisor
)

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
  email: 'inactive2@example.com',
  password: '123456',
  password_confirmation: '123456',
  role: :inactive
)

# create CasaCases and assign volunteers to them
case_1 = CasaCase.create(
  case_number: "111"
)

case_assignment_1 = CaseAssignment.create(
  casa_case: case_1,
  volunteer: volunteer_user_1
)

case_2 = CasaCase.create(
  case_number: "222",
  transition_aged_youth: true
)

case_assignment_2 = CaseAssignment.create(
  casa_case: case_2,
  volunteer: volunteer_user_1
)

# associate half of the volunteers with supervisor_user_1, half with supervisor_user_2
volunteer_users.each_with_index do | volunteer_user, i |
  supervisor_user = i % 2 != 0 ? supervisor_user_1 : supervisor_user_2
  SupervisorVolunteer.create(
    [
      { supervisor_id: supervisor_user.id, volunteer_id: volunteer_user.id }
    ]
  )
end

# create CaseContact and associate with CasaCase, volunteer creator and include data
CaseContact.create(
  [
    { casa_case_id: case_1.id, creator_id: volunteer_user_1.id, duration_minutes: 15, occurred_at: DateTime.new(2020, 2, 3, 4, 5, 6), contact_type: :school },
    { casa_case_id: case_1.id, creator_id: volunteer_user_1.id, duration_minutes: 15, occurred_at: DateTime.new(2020, 2, 10), contact_type: :school }
  ]
)
