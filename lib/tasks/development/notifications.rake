if Rails.env.development?
  desc "Create a emancipation_checklist_reminder_notifier notification"
  task emancipation_checklist_reminder_notifier: :environment do
    CasaCase.birthday_next_month.find_each do |casa_case|
      casa_case.case_assignments.active.find_each do |case_assignment|
        EmancipationChecklistReminderNotifier
          .with(casa_case: casa_case)
          .deliver(Volunteer.find_by(id: case_assignment.volunteer_id))
      end
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
end
