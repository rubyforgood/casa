require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe ApplicationController, type: :controller do
  let(:volunteer) { create(:volunteer) }
  # add domains to blacklist you want to stub
  blacklist = ["api.short.io"]
  web_mock = WebMockHelper.new(blacklist)
  web_mock.stub_network_connection
  # stub application controller methods
  controller do
    def index
      render plain: "hello there..."
    end

    # input => array of urls
    # output => hash of valid short urls {id => short url/nil}
    def handle_short_url(url_list)
      super
    end

    def not_authorized_error
      raise Pundit::NotAuthorizedError
    end

    def unknown_organization
      raise Organizational::UnknownOrganization
    end
  end

  before do
    # authorize user
    # sign in as an admin
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
    @short_io_stub = WebMockHelper.short_io_stub_sms
    @short_io_error_stub = WebMockHelper.short_io_error_stub
  end

  describe "#index" do
    it "does not store URL path for POST" do
      path = "/index"
      session_key = "user_return_to"
      routes.draw { post "index" => "anonymous#index" }
      post :index
      expect(session[session_key]).not_to eq path
      expect(session[session_key]).to be nil
    end
  end

  describe "handle_short_url" do
    it "returns a hash of shortened urls" do
      input_list = ["www.clubpenguin.com", "www.miniclip.com"]
      output_hash = controller.handle_short_url(input_list)
      expect(output_hash[0]).to eq("https://42ni.short.gy/jzTwdF")
      expect(output_hash[1]).to eq("https://42ni.short.gy/jzTwdF")
      expect(output_hash.length).to eq(2)
      expect(@short_io_stub).to have_been_requested.times(2)
    end

    it "returns a hash with a mix of valid/invalid short urls" do
      input_list = ["www.clubpenguin.com", "www.badrequest.com", "www.miniclip.com"]
      output_hash = controller.handle_short_url(input_list)
      expect(output_hash[1]).to eq(nil)
      expect(output_hash.length).to eq(3)
      expect(@short_io_stub).to have_been_requested.times(3)
      expect(@short_io_error_stub).to have_been_requested.times(1)
    end
  end

  describe "Raise error: " do
    it "should redirect to root_url if rescued Pundit::NotAuthorizedError" do
      routes.draw { get :not_authorized_error, to: "anonymous#not_authorized_error" }
      get :not_authorized_error
      expect(response).to redirect_to(root_url)
    end

    it "should redirect to root_url if rescued Organizational::UnknownOrganization" do
      routes.draw { get :unknown_organization, to: "anonymous#unknown_organization" }
      get :unknown_organization
      expect(response).to redirect_to(root_url)
    end
  end

  describe "After signin path" do
    it "should be equal to initial path" do
      routes.draw { get :index, to: "anonymous#index" }
      get :index
      path = controller.after_sign_in_path_for(volunteer)
      expect(path).to eq("/index")
    end
  end

  describe "After signout path" do
    it "should be equal to new_all_casa_admin_session_path" do
      path = controller.after_sign_out_path_for(:all_casa_admin)
      expect(path).to eq(new_all_casa_admin_session_path)
    end
    it "should be equal to root_path" do
      path = controller.after_sign_out_path_for(volunteer)
      expect(path).to eq(root_path)
    end
  end

  describe "sms acct creation notice" do
    it "sms status is blank" do
      expect(controller.send(:sms_acct_creation_notice, "admin", "blank")).to eq("New admin created successfully.")
    end

    it "sms status is error" do
      expect(controller.send(:sms_acct_creation_notice, "admin", "error")).to eq("New admin created successfully. SMS not sent. Error: .")
    end

    it "sms status is sent" do
      expect(controller.send(:sms_acct_creation_notice, "admin", "sent")).to eq("New admin created successfully. SMS has been sent!")
    end
  end

  describe "deliver_sms_to encounters an error" do
    let(:organization_twilio_disabled) { create(:casa_org, twilio_enabled: false) }

    context "when twilio is not enabled" do 
      it "raises a TwilioCasaOrgError" do
        expect { TwilioService.new(organization_twilio_disabled) }.to raise_error(TwilioService::TwilioCasaOrgError)
      end
    end
  end
end
