# frozen_string_literal: true

# Helper methods for new/edit contact type form
module ContactTypesHelper
  def set_group_options
    @group_options = ContactTypeGroup.for_organization(current_organization).collect { |group| [group.name, group.id] }
  end
end
