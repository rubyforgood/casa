module SessionHelper
  def sign_in_as_admin
    sign_in(CasaAdmin.first || create(:casa_admin))
  end

  def sign_in_as_volunteer
    sign_in(Volunteer.first || create(:volunteer))
  end

  # TODO use this more
  def sign_in_as_supervisor
    sign_in(Supervisor.first || create(:supervisor))
  end

  # TODO use this more
  def sign_in_as_all_casa_admin
    sign_in(AllCasaAdmin.first || create(:all_casa_admin))
  end
end
