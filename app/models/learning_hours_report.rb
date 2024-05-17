class LearningHoursReport
  attr_reader :learning_hours

  def initialize(casa_org_id)
    @learning_hours = LearningHour.includes(:user)
      .where(user: {casa_org_id: casa_org_id})
      .order(:id)
  end

  def to_csv
    LearningHoursExportCsvService.new(@learning_hours).perform
  end
end
