# frozen_string_literal: true

class ErrorController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def index
  end

  def create
    raise StandardError.new "This is an intentional test exception"
  end
end
