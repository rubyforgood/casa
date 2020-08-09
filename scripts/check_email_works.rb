your_email = 
casa_org_name = "Prince George CASA"
casa_org = CasaOrg.find_by(name: casa_org_name)
unless obj
  casa_org = CasaOrg.create(name: casa_org_name)
end

ca = CasaAdmin.find_by(email: your_email)
unless ca
  ca = CasaAdmin.new(
      casa_org_id: casa_org.id,
      display_name: "Ruby for Good",
      email: "compiledwrong@gmail.com",
      password: "123456",
      password_confirmation: "123456"
  )
  ca.save
end
ca.invite! # sends devise email

# send a different specific email to the user, directly
VolunteerMailer.account_setup(ca)
