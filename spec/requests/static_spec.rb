# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/", type: :request do
  describe "GET /" do
    subject(:request) do
      get root_path

      response
    end

    it { is_expected.to be_successful }
  end
end
