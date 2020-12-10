require "active_support/concern"

module ByOrganizationScope
  extend ActiveSupport::Concern

  included do
    scope :by_organization, ->(casa_org) { where(casa_org: casa_org) }
  end
end
