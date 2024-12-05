require "rails_helper"

RSpec.describe Rack::Attack do
  include Rack::Test::Methods

  # https://makandracards.com/makandra/46189-how-to-rails-cache-for-individual-rspec-tests
  # memory store is per process and therefore no conflicts in parallel tests
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:header) { {"REMOTE_ADDR" => remote_ip} }
  let(:params) { {} }
  let(:limit) { 5 }
  let(:cache) { Rails.cache }

  before do
    Rack::Attack.enabled = true
    ActionController::Base.perform_caching = true
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
    freeze_time
  end

  after do
    ActionController::Base.perform_caching = false
  end

  def app
    Rails.application
  end

  describe "throttle excessive requests by single IP address" do
    shared_examples "correctly throttles" do
      it "changes the request status to 429 if greater than limit" do
        (limit * 2).times do |i|
          post path, params, header
          expect(last_response.status).not_to eq 429 if i < limit
          expect(last_response.status).to eq(429) if i >= limit
        end
      end
    end

    it_behaves_like "correctly throttles" do
      let(:path) { "/users/sign_in" }
      let(:remote_ip) { "111.200.300.123" }
    end

    it_behaves_like "correctly throttles" do
      let(:path) { "/all_casa_admins/sign_in" }
      let(:remote_ip) { "111.200.300.456" }
    end
  end

  describe "localhost is not throttled" do
    let(:remote_ip) { "127.0.0.1" }
    let(:path) { "/users/sign_in" }

    it "does not change the request status to 429" do
      (limit * 2).times do |i|
        post path, params, header
        expect(last_response.status).not_to eq(429) if i > limit
      end
    end
  end

  describe "throttle excessive requests for email login by variety of IP addresses" do
    shared_examples "correctly throttles" do
      it "changes the request status to 429 when greater than limit" do
        (limit * 2).times do |i|
          header = {"REMOTE_ADDR" => "#{remote_ip}#{i}"}
          post path, params, header
          expect(last_response.status).not_to eq 429 if i < limit
          expect(last_response.status).to eq(429) if i >= limit
        end
      end
    end

    it_behaves_like "correctly throttles" do
      let(:user) { create(:user, email: "foo@example.com") }
      let(:remote_ip) { "189.23.45.1" }
      let(:path) { "/users/sign_in" }
      let(:params) {
        {
          user: {
            email: user.email,
            password: "badpassword"
          }
        }
      }
    end

    it_behaves_like "correctly throttles" do
      let(:user) { create(:all_casa_admin, email: "bar@example.com") }
      let(:remote_ip) { "199.23.45.1" }
      let(:path) { "/all_casa_admins/sign_in" }
      let(:first_block) { "223" }
      let(:params) {
        {
          all_casa_admin: {
            email: user.email,
            password: "badpassword"
          }
        }
      }
    end
  end

  context "blocklist" do
    let(:path) { "/users/sign_in" }

    context "good ip" do
      let(:remote_ip) { "101.202.103.104" }

      it "is not blocked" do
        post path, params, header
        expect(last_response.status).not_to eq(403)
      end
    end

    context "bad ips" do
      # IP_BLOCKLIST environment variable set in config/environments/test.rb
      shared_examples "blocks request" do
        it "changes the request status to 403" do
          post path, params, header
          expect(last_response.status).to eq(403)
        end
      end

      it_behaves_like "blocks request" do
        let(:remote_ip) { "4.5.6.7" }
      end

      it_behaves_like "blocks request" do
        let(:remote_ip) { "9.8.7.6" }
      end

      it_behaves_like "blocks request" do
        let(:remote_ip) { "100.101.102.103" }
      end
    end
  end

  describe "fail2ban" do
    shared_examples "bans successfully" do
      it "changes the request status to 403" do
        head path, params, header
        expect(last_response.status).to eq(403)
      end
    end

    context "phpmyadmin" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "1.2.33.4" }
        let(:path) { "/phpMyAdmin/" }
      end
    end

    context "phpmyadmin4" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "55.66.77.88" }
        let(:path) { "/phpMyAdmin4/" }
      end
    end

    context "sql/phpmy-admin" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.66.77.99" }
        let(:path) { "/sql/phpmy-admin/" }
      end
    end

    context "db/phpmyadmin-32" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.96.77.99" }
        let(:path) { "/db/phpMyAdmin-3/" }
      end
    end

    context "sqlmanager" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.95.77.99" }
        let(:path) { "/mysql/mysqlmanager/" }
      end
    end

    context "PMA year" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.94.77.99" }
        let(:path) { "/PMA2014" }
      end
    end

    context "mysql" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.93.77.99" }
        let(:path) { "/mysql/dbadmin/" }
      end
    end

    context "config/server" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.92.77.99" }
        let(:path) { "/config/server" }
      end
    end

    context "config/server" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.91.77.99" }
        let(:path) { "/_ServerStatus" }
      end
    end

    context "etc/services" do
      it_behaves_like "bans successfully" do
        let(:remote_ip) { "44.89.77.99" }
        let(:path) { "/etc/services" }
      end
    end
  end
end
