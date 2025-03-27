class FundRequest < ApplicationRecord
  validates :submitter_email, presence: true
end

# == Schema Information
#
# Table name: fund_requests
#
#  id                            :bigint           not null, primary key
#  deadline                      :text
#  extra_information             :text
#  impact                        :text
#  other_funding_source_sought   :text
#  payee_name                    :text
#  payment_amount                :text
#  request_purpose               :text
#  requested_by_and_relationship :text
#  submitter_email               :text
#  timestamps                    :text
#  youth_name                    :text
#
