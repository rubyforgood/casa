# frozen_string_literal: true

class ErrorController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render status: 500
  end
end
