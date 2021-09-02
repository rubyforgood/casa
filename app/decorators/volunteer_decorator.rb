class VolunteerDecorator < UserDecorator
  include Draper::LazyHelpers

  def cc_reminder_text
    if h.current_user.supervisor?
      checkbox_text = "Send CC to Supervisor"
    elsif h.current_user.casa_admin?
      checkbox_text = "Send CC to Supervisor and Admin"
    end

    checkbox_text
  end
end
