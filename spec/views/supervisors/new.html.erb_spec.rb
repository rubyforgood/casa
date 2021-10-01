require "rails_helper"

RSpec.describe "supervisors/new", type: :view do
  subject { render template: "supervisors/new" }

  before do
    assign :supervisor, Supervisor.new
  end

  context "while signed in as admin" do
    before do
      sign_in_as_admin
    end
  end
end
