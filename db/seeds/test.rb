User.destroy_all
seed_password = "123456"

volunteer = Volunteer.first_or_create!(
  casa_org: pg_casa,
  display_name: Faker::Name.name,
  email: "volunteer1@example.com",
  password: seed_password,
  password_confirmation: seed_password
)