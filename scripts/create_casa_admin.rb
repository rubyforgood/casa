# We plan to build this function in the UI but for now this is the only way to create a CASA admin
def create_admin(casa_org, new_admin_email)
  ca = CasaAdmin.find_by(email: new_admin_email)
  unless ca
    ca = CasaAdmin.new(
      casa_org_id: casa_org.id,
      display_name: new_admin_email.split("@")[0],
      email: new_admin_email,
      password: "123456", # Devise requires that this be changed before allowing login
      password_confirmation: "123456"
    )
    ca.save
  end
  ca.invite! # sends devise email
end

new_admin_email = ""
casa_org_name = "Prince George CASA"
casa_org = CasaOrg.find_by(name: casa_org_name)

create_admin(casa_org, new_admin_email)
