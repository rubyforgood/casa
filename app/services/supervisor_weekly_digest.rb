class SupervisorWeeklyDigest
  def initialize(casa_org = nil)
    @casa_org = casa_org
  end

  def send!
    if @casa_org
      send_for_org(@casa_org)
    else
      CasaOrg.find_each do |org|
        send_for_org(org)
      end
    end
  end

  private

  def send_for_org(org)
    org.with_time_zone do
      unless org.today.monday?
        Rails.logger.info { "Supervisor Weekly Digest skipped for CasaOrg #{org.id}. Today is not Monday in #{org.time_zone}." }
        return
      end

      week_start = org.time_zone_now.beginning_of_week.utc

      org.supervisors.active.find_each do |supervisor|
        already_sent = SentEmail.where(
          user_id: supervisor.id,
          mailer_type: "SupervisorMailer",
          category: "Weekly digest"
        ).where("created_at >= ?", week_start).exists?

        if already_sent
          Rails.logger.info { "Weekly digest already sent to supervisor #{supervisor.id} for the week of #{org.today.beginning_of_week}." }
          next
        end

        SupervisorMailer.weekly_digest(supervisor).deliver_now
      end
    end
  rescue => e
    Rails.logger.error("Failed sending supervisor weekly digest for CasaOrg #{org.id}: #{e.message}")
  end
end
