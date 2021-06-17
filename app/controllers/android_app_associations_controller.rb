class AndroidAppAssociationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    render file: Rails.root.join("public", "assetlinks.json")
  end
end
