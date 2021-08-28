class VolunteerDecorator < UserDecorator
  include Draper::LazyHelpers
  delegate_all

  def send_reminder_button
    submit_tag(
      t(".send_reminder"),
      class: "btn btn-primary casa-case-button",
      data_toggle: "tooltip",
      title: t(".tooltip").to_s
    )
  end

  def cc_reminder_text
    if current_user.supervisor?
      checkbox_text = "Send CC to Supervisor"
    elsif current_user.casa_admin?
      checkbox_text = "Send CC to Supervisor and Admin"
    end

    checkbox_text
  end
end
