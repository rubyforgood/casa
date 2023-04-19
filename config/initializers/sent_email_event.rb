ActiveSupport::Notifications.subscribe "process.action_mailer" do |*args|
  data = args.extract_options!
  next if data[:mailer] == "DebugPreviewMailer"

  user = data[:args][0]
  if user&.role != "All Casa Admin"
    SentEmail.create(
      casa_org_id: user&.casa_org_id,
      user_id: user&.id,
      sent_address: user&.email,
      mailer_type: data[:mailer],
      category: data[:action].to_s.humanize
    )
    Rails.logger.info "#{data[:action]} email saved!"
  end
end
