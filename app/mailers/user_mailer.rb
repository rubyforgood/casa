class UserMailer < ApplicationMailer
  def password_changed_reminder(user)
    @user = user
    @casa_organization = user.try(:casa_org) || nil

    mail(to: @user.email, subject: "CASA Password Changed")
  end

  def followup_notification(user, followup)
    @user = user
    @followup = followup
    @case_contact = followup.case_contact
    @casa_organization = user.try(:casa_org)
    mail(to: @user.email, subject: "A case contact needs follow-up")
  end

  def followup_resolved(user, followup)
    @user = user
    @followup = followup
    @case_contact = followup.case_contact
    @casa_organization = user.try(:casa_org)
    mail(to: @user.email, subject: "A case contact follow-up was resolved")
  end
end
