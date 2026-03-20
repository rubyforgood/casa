require "rails_helper"

RSpec.describe "/error", type: :request do
  describe "GET /error" do
    it "renders the error test page" do
      get error_path

      expect(response).to be_successful
    end
  end

  describe "POST /error" do
    it "raises an error causing an internal server error" do
      expect {
        post error_path
      }.to raise_error(StandardError, /This is an intentional test exception/)
    end
  end
end
