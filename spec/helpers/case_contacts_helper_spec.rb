require "rails_helper"

describe CaseContactsHelper do
  describe "#render_back_link" do
    it "renders back link to home page when user is a volunteer" do
      current_user = create(:volunteer)
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.render_back_link(casa_case)).to eq(root_path)
    end

    it "renders back link to home page when user does not exist" do
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(nil)

      expect(helper.render_back_link(casa_case)).to eq(root_path)
    end

    it "renders back link to home page when user is a supervisor" do
      current_user = create(:supervisor)
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.render_back_link(casa_case)).to eq(casa_case_path(casa_case))
    end

    it "renders back link to home page when user is a administrator" do
      current_user = create(:casa_admin)
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.render_back_link(casa_case)).to eq(casa_case_path(casa_case))
    end
  end
end
