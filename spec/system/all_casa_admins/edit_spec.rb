require "rails_helper"

RSpec.describe "all_casa_admin_edit_spec", type: :system do
  let(:admin) {create(:all_casa_admin)}

  before do
    sign_in admin
  end

  describe"with valid parameters" do
    it "updates email" do
    end
  end
end
