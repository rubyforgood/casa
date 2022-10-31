class LanguagePolicy < ApplicationPolicy
  alias_method :add_language?, :is_volunteer?
  alias_method :remove_from_volunteer?, :is_volunteer?
end
