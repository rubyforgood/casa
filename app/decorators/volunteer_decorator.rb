class VolunteerDecorator < UserDecorator
  include Draper::LazyHelpers

  def cc_reminder_text
    if h.current_user.supervisor?
      "Send CC to Supervisor"
    elsif h.current_user.casa_admin?
      "Send CC to Supervisor and Admin"
    end
  end
end
