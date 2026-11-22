# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/", type: :request do
  describe "GET /" do
    subject(:request) do
      get root_path

      response
    end

    it { is_expected.to be_successful }

    context "with an invalid Accept header" do
      subject(:request) do
        get root_path, headers: {"Accept" => "../../../../../../../../etc/passwd{{"}

        response
      end

      it { is_expected.to have_http_status(:not_acceptable) }
    end

    context "with an invalid Content-Type header" do
      subject(:request) do
        get root_path, headers: {"Content-Type" => "../../../../../../../../etc/passwd{{"}

        response
      end

      it { is_expected.to have_http_status(:not_acceptable) }
    end
  end
end
