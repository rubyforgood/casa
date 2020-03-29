# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

all_casa_admin_1 = AllCasaAdmin.create({
                                         email: 'all_casa_admin1@example.com',
                                         password: '123456',
                                         password_confirmation: '123456'
                                       })

pg_casa = CasaOrg.create(name: 'Prince George CASA')
other_casa = CasaOrg.create(name: 'Other CASA org')

case_1 = CasaCase.create({ case_number: 111 })
case_2 = CasaCase.create({ case_number: 222, teen_program_eligible: true })

volunteer_user_1 = User.create({
                                 casa_org_id: pg_casa.id,
                                 email: 'volunteer1@example.com',
                                 password: '123456',
                                 password_confirmation: '123456',
                                 role: :volunteer
                               })
supervisor_user_1 = User.create({
                                  casa_org_id: pg_casa.id,
                                  email: 'supervisor1@example.com',
                                  password: '123456',
                                  password_confirmation: '123456',
                                  role: :supervisor
                                })
casa_admin_user_1 = User.create({
                                  casa_org_id: pg_casa.id,
                                  email: 'casa_admin1@example.com',
                                  password: '123456',
                                  password_confirmation: '123456',
                                  role: :casa_admin
                                })
inactive_user_1 = User.create({
                                casa_org_id: pg_casa.id,
                                email: 'inactive1@example.com',
                                password: '123456',
                                password_confirmation: '123456',
                                role: :inactive
                              })

SupervisorVolunteer.create(
  [
    { supervisor_id: supervisor_user_1.id, volunteer_id: volunteer_user_1.id }
  ]
)

CaseAssignment.create(
  [
    { casa_case_id: case_1.id, volunteer_id: volunteer_user_1.id }
  ]
)

CaseContact.create(
  [
    { casa_case_id: case_1.id, creator_id: volunteer_user_1.id, duration_minutes: 15, occurred_at: DateTime.new(2020, 2, 3, 4, 5, 6), contact_type: :school },
    { casa_case_id: case_1.id, creator_id: volunteer_user_1.id, duration_minutes: 15, occurred_at: DateTime.new(2020, 2, 10), contact_type: :other, other_type_text: 'asd' }
  ]
)
