class MileageRatePolicy < ApplicationPolicy
  # A mileage rate belongs_to :casa_org, so every action can -- and must -- check the record's org.
  # The controller used to `authorize CasaAdmin`, passing the *class*: that skipped the org check
  # entirely (any admin could edit any org's rate) and raised NoMethodError in `same_org?`, because
  # CasaAdminPolicy#edit? is the one method there that reaches record.casa_org.
  def new?
    is_admin_same_org?
  end

  alias_method :create?, :new?
  alias_method :edit?, :new?
  alias_method :update?, :new?
end
