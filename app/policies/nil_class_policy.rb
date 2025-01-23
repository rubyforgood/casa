class NilClassPolicy < ApplicationPolicy
  def method_missing(*)
    false
  end

  def respond_to_missing?(*)
    true
  end
end
