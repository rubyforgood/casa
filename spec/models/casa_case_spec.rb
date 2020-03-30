require 'rails_helper'

RSpec.describe CasaCase, type: :model do
  it do
    is_expected.to(
      belong_to(:volunteer).class_name("User").inverse_of(:casa_cases)
    )
  end
end
