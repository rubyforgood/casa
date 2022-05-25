# Helper methods for new case contact form
module OtherDutiesHelper
  def duration_hours(duty)
    duty.duration_minutes.to_i.div(60)
  end

  def duration_minutes(duty)
    duty.duration_minutes.to_i.remainder(60)
  end
end
