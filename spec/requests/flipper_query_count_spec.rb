require "rails_helper"

# https://github.com/rubyforgood/casa/issues/7397
# A flag-guarded page must not run one flipper query per flag check: the
# Memoizer middleware (config/application.rb) caps each flag at one adapter
# load per request.
#
# The test env normally swaps Flipper's default adapter for an in-memory one
# (flipper/test_help), so this spec re-runs the real initializer.
RSpec.describe "Flipper query count on a flag-guarded page", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }

  before { sign_in admin }

  around do |example|
    with_real_flipper_adapter { example.run }
  end

  describe "GET /casa_org/:id/edit (checks :show_additional_expenses in the view)" do
    it "does not grow the flipper query count with the number of flag checks" do
      get edit_casa_org_path(casa_org)
      expect(response).to have_http_status(:success)

      baseline = count_flipper_queries { get edit_casa_org_path(casa_org) }
      expect(baseline).to be_positive

      # Simulate the flag being checked many times during the request.
      allow(Flipper).to receive(:enabled?).and_wrap_original do |original, *args|
        10.times { original.call(*args) }
      end

      queries_with_many_checks = count_flipper_queries { get edit_casa_org_path(casa_org) }

      # One adapter load per distinct flag per request (feature row + gates),
      # not one query per `Flipper.enabled?` call.
      expect(queries_with_many_checks).to eq(baseline)
      expect(queries_with_many_checks).to be <= 2
    end
  end
end
