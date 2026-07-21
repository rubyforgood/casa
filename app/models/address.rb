class Address < ApplicationRecord
  belongs_to :user

  STRUCTURED_FIELDS = %i[line_1 line_2 city state zip].freeze

  before_save :compose_content, if: :structured?

  # True once the address has been captured as discrete parts (line 1 / city / state / zip)
  # rather than only the legacy single `content` string. Legacy rows (only `content` set) are
  # left untouched so their display value is preserved and existing specs/factories still work.
  def structured?
    STRUCTURED_FIELDS.any? { |field| self[field].present? }
  end

  private

  # `content` remains the canonical, human-readable one-line address the rest of the app reads
  # (reimbursement table, mileage CSV export, case-contact prefill), so keep it in sync with the
  # structured parts instead of changing every reader. A line_1-only address composes back to
  # exactly line_1, which is why the backfill can safely put legacy content into line_1.
  def compose_content
    region = [city, [state, zip].compact_blank.join(" ")].compact_blank.join(", ")
    self.content = [line_1, line_2, region].compact_blank.join(", ")
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id         :bigint           not null, primary key
#  city       :string
#  content    :string
#  line_1     :string
#  line_2     :string
#  state      :string
#  zip        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_addresses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
