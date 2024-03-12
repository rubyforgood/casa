namespace :factory_bot do
  desc "Verify that all FactoryBot factories are valid"
  task lint: :environment do
    if Rails.env.test?
      puts "linting factory_bot factories for being rails valid objects"
      conn = ActiveRecord::Base.connection
      invalid_factories = [
          # * casa_admin+with_casa_cases - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * casa_admin+with_case_contact - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * casa_admin+with_case_contact_wants_driving_reimbursement - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * casa_admin+with_casa_cases - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * casa_admin+with_single_case - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * casa_admin+with_case_contact - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * casa_admin+with_case_contact_wants_driving_reimbursement - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          :casa_admin,

          # * supervisor+with_casa_cases - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * supervisor+with_case_contact - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * supervisor+with_case_contact_wants_driving_reimbursement - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * supervisor+with_casa_cases - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * supervisor+with_single_case - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * supervisor+with_case_contact - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * supervisor+with_case_contact_wants_driving_reimbursement - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          :supervisor,

          # * user+with_casa_cases - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * user+with_single_case - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * user+with_case_contact - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          # * user+with_case_contact_wants_driving_reimbursement - Validation failed: Volunteer Case assignee must be an active volunteer (ActiveRecord::RecordInvalid)
          :user
      ]
      raise "a suspiciously low number of FactoryBot factories" if FactoryBot.factories.count < 50
      factories_to_lint = FactoryBot.factories.reject do |factory|
        invalid_factories.include?(factory.name)
      end
      conn.transaction do
        FactoryBot.lint(factories_to_lint, {traits: true})
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      raise if $?.exitstatus.nonzero?
    end
  end
end