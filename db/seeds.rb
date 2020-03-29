# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

casa_cases = CasaCase.create(
    [
        {case_number: 111},
        {case_number: 222, teen_program_eligible: true},
    ]
)

users = User.create(
    [
        {
            email: "volunteer1@example.com",
            password: "123456",
            password_confirmation: "123456",
            role: :volunteer
        },
        {
            email: "supervisor1@example.com",
            password: "123456",
            password_confirmation: "123456",
            role: :supervisor
        },
        {
            email: "casa_admin1@example.com",
            password: "123456",
            password_confirmation: "123456",
            role: :casa_admin
        },
        {
            email: "inactive1@example.com",
            password: "123456",
            password_confirmation: "123456",
            role: :inactive
        },
    ]
)
