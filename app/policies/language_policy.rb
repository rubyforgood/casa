class LanguagePolicy < ApplicationPolicy
  alias_method :add_to_volunteer?, :is_volunteer?
  alias_method :remove_from_volunteer?, :is_volunteer?
end
