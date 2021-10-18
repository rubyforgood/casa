class SupervisorWeeklyDigest
  def send!
    if Time.now.monday?
      Supervisor.active.find_each do |supervisor|
        SupervisorMailer.weekly_digest(supervisor).deliver_now
      end
    end
  end
end
