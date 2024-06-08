desc "Create a notification for volunteers when a youth has a birthday coming in the next month, scheduled for the 15th of each month in Heroku Scheduler"
task youth_birthday_reminder: :environment do
  CasaCase.birthday_next_month.each do |casa_case|
    YouthBirthdayNotifier
      .with(casa_case: casa_case)
      .deliver(Volunteer.find_by(id: casa_case.case_assignments.first.volunteer_id))
  end
end

desc "Create a emancipation_checklist_reminder_notifier notification"
task emancipation_checklist_reminder_notifier: :environment do
  CasaCase.birthday_next_month.each do |casa_case|
    EmancipationChecklistReminderNotifier
      .with(casa_case: casa_case)
      .deliver(Volunteer.find_by(id: casa_case.case_assignments.first.volunteer_id))
  end
end

desc "Create a followup_notifier notification"
task followup_notifier: :environment do
  followup = Followup.all.first
  deliver_from = User.all.to_a.last

  FollowupNotifier
    .with(followup: followup, created_by: deliver_from)
    .deliver(User.find_by(id: 1))
end

desc "Create a reimbursement_complete_notifier notification"
task reimbursement_complete_notifier: :environment do
  ReimbursementCompleteNotifier
    .with(case_contact: CaseContact.all.first)
    .deliver(User.find_by(id: 1))
end