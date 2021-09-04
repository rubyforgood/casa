class VolunteerDecorator < UserDecorator
  include Draper::LazyHelpers

  def cc_reminder_text
    if h.current_user.supervisor?
      h.t("volunteers.send_reminder_button.supervisor_checkbox_text")
    elsif h.current_user.casa_admin?
      h.t("volunteers.send_reminder_button.admin_checkbox_text")
    end
  end
end
