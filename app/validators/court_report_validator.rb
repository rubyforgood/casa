# Validation class for :court_report_status & :court_report_submitted_at. Adds specific errors based on record data.
class CourtReportValidator < ActiveModel::Validator
  def validate(record)
    # Check for no timestamp and a submission value other than 'not_submitted'.
    if record.court_report_submitted_at.nil? && !record.court_report_not_submitted?
      record.errors.add(:court_report_status, "Court report submission date can't be nil if status is anything but not_submitted.")
    # Check for timestamp with a 'not_submitted' status.
    elsif record.court_report_submitted_at && record.court_report_not_submitted?
      record.errors.add(:court_report_submitted_at, "Submission date must be nil if court report status is not submitted.")
    end
  end
end
