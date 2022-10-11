desc "Create a notification for volunteers with transition aged youth to utilize the Emancipation Checklist, scheduled once per month in Heroku Scheduler"
task emancipation_checklist_reminder: :environment do
  if Date.today.day == 1
    CaseAssignment.active.includes(:casa_case, :volunteer).where(casa_cases: {birth_month_year_youth: ..14.years.ago}).each do |assignment|
      EmancipationChecklistReminderNotification
        .with(casa_case: assignment.casa_case)
        .deliver(assignment.volunteer)
    end
  end
end
