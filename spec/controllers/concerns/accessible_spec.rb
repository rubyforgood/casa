require "rails_helper"

class MockController < ApplicationController
  before_action :reset_session, only: :no_session_action
  include Accessible
  def action
    render plain: "controller action test..."
  end

  def no_session_action
    render plain: "controller action test..."
  end
end

RSpec.describe MockController, type: :controller do
  let(:admin) { create(:casa_admin) }
  let(:volunteer) { create(:volunteer) }

  before do
    routes.disable_clear_and_finalize = true
    routes.draw do 
      get :action, to: "mock#action"
      get :no_session_action, to: "mock#no_session_action"
    end
  end

  context "Authenticated user" do
    it "should redirect to authenticated casa admin root path" do
      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_all_casa_admin).and_return(admin)
      get :action
      expect(response).to redirect_to authenticated_all_casa_admin_root_path
    end
  
    it "should redirect to authenticated user root path" do
      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(volunteer)
      get :no_session_action
      expect(response).to redirect_to authenticated_user_root_path
    end
  end
end
