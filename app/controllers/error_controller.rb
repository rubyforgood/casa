# frozen_string_literal: true

class ErrorController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped # TODO: index should call policy_scope; remove this skip once it does

  def index
  end

  def create
    raise StandardError.new "This is an intentional test exception"
  end
end
