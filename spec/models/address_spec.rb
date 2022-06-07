require 'rails_helper'

RSpec.describe Address, type: :model do
  describe "validate associations" do
    it { should belong_to(:user) }
  end
end
