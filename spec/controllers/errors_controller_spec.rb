require "rails_helper"

RSpec.describe ErrorsController, type: :controller do
  it "return a 404" do
    get :not_found

    expect(response.status).to eq(404)
  end

  it "return a 500" do
    get :internal_server_error

    expect(response.status).to eq(500)
  end
end
