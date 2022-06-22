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
    def handle_short_url(urlList)
      super
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
end
