User.destroy_all
seed_password = "123456"
pg_casa = CasaOrg.where(name: "Prince George CASA").first_or_create!(
  casa_org_logo: logo,
  display_name: "CASA / Prince George's County, MD",
  address: "6811 Kenilworth Avenue, Suite 402 Riverdale, MD 20737",
  footer_links: [
    ["https://pgcasa.org/contact/", "Contact Us"],
    ["https://pgcasa.org/subscribe-to-newsletter/", "Subscribe to newsletter"],
    ["https://www.givedirect.org/give/givefrm.asp?CID=4450", "Donate"]
  ]
)
volunteer = Volunteer.first_or_create!(
  casa_org: pg_casa,
  display_name: Faker::Name.name,
  email: "volunteer1@example.com",
  password: seed_password,
  password_confirmation: seed_password
)