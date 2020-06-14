require "rails_helper"

class RouteRecognizer
  attr_reader :paths

  def self.routes
    @routes ||= Rails.application.routes.routes.collect { |r| Route.new(r) }
  end

  class Route
    attr_reader :name, :path, :verb, :controller, :action

    def initialize(route_data)
      @path = route_data.path.spec.to_s.split("(").first.gsub(/:\w+/, "1")
      @verb = route_data.verb
      @controller = route_data.defaults[:controller]
      @action = route_data.defaults[:action]
      @name = (route_data.name || "#{@action}_#{@controller}") + " (#{@action})"
    end

    def to_h
      {name: @name, path: @path, verb: @verb, controller: @controller, action: @action}
    end

    def is_a_rails_path?
      @path.starts_with?("/rails") || @path.starts_with?("/assets") || @path.starts_with?("/cable")
    end

    def is_a_devise_controlled_route?
      @controller.starts_with?("devise")
    end
  end
end

RSpec.describe "All Endpoints", type: :request do
  describe "require authorization" do
    RouteRecognizer.routes.each do |route|
      begin
        next if route.is_a_rails_path? || route.is_a_devise_controlled_route?
      rescue NoMethodError => e
        puts "Error: #{e}"
        p route
      end

      it "Redirects to the sign_in page with #{route.name}" do
        send(route.verb.downcase.to_sym, route.path)
        expect(response.status).to eq(302)
        expect(response.header["Location"]).to be_end_with("sign_in")
      end
    end
  end
end
