require "rails_helper"

RSpec.describe "court_dates/show", type: :view do
  RSpec.shared_examples_for "a past court date with all court details" do
    let(:court_date) { create(:court_date, :with_court_details) }
    let(:case_court_order) { court_date.case_court_orders.first }

    before { render template: "court_dates/show" }

    it "displays all court details" do
      expect(rendered).to include("/casa_cases/#{court_date.casa_case.case_number.parameterize}")
      expect(rendered).to include(ERB::Util.html_escape(court_date.judge.name))
      expect(rendered).to include(court_date.hearing_type.name)

      expect(rendered).to include(case_court_order.text)
      expect(rendered).to include(case_court_order.implementation_status.humanize)
    end

    context "when judge's name has escaped characters" do
      let(:court_date) { create(:court_date, :with_court_details, judge: create(:judge, name: "/-'<>#&")) }

      it "correctly displays judge's name" do
        expect(rendered).to include(ERB::Util.html_escape(court_date.judge.name))
      end
    end

    it "displays the download button for .docx" do
      expect(rendered).to include "Download Report (.docx)"
      expect(rendered).to include "/casa_cases/#{court_date.casa_case.case_number.parameterize}/court_dates/#{court_date.id}.docx"
    end
  end

  RSpec.shared_examples_for "a past court date with no court details" do
    let(:court_date) { create(:court_date) }

    it "displays all court details" do
      render template: "court_dates/show"

      expect(rendered).to include("Judge:")
      expect(rendered).to include("Hearing Type")
      expect(rendered).to include("None")

      expect(rendered).to include("There are no court orders associated with this court date.")
    end
  end

  let(:organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  before do
    enable_pundit(view, user)

    assign :casa_case, court_date.casa_case
    assign :court_date, court_date

    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "with court details" do
    context "when accessed by a casa admin" do
      let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

      it_behaves_like "a past court date with all court details"
    end

    context "when accessed by a supervisor" do
      let(:user) { build_stubbed(:supervisor, casa_org: organization) }

      it_behaves_like "a past court date with all court details"
    end

    context "when accessed by a volunteer" do
      let(:user) { build_stubbed(:volunteer, casa_org: organization) }

      it_behaves_like "a past court date with all court details"
    end
  end

  context "without court details" do
    context "when accessed by an admin" do
      let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

      it_behaves_like "a past court date with no court details"
    end

    context "when accessed by a supervisor" do
      let(:user) { build_stubbed(:supervisor, casa_org: organization) }

      it_behaves_like "a past court date with no court details"
    end

    context "when accessed by a volunteer" do
      let(:user) { build_stubbed(:volunteer, casa_org: organization) }

      it_behaves_like "a past court date with no court details"
    end
  end
end
