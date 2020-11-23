class VolunteerDecorator < UserDecorator
  def last_contact_made
    if object.most_recent_contact.nil?
      "None ❌"
    else
      object.most_recent_contact.occurred_at.strftime("%B %-e, %Y")
    end
  end

  def datatable
    DatatableDecorator.new object.decorate
  end

  class DatatableDecorator < VolunteerDecorator
    attr_reader :object

    def initialize(object)
      super
      @object = object
    end

    def link_to_edit(text = nil)
      h.link_to h.edit_volunteer_path object do
        text || "#{object.name}#{!object.made_contact_with_all_cases_in_14_days? ? " 🕐" : nil}"
      end
    end

    def link_to_edit_supervisor
      return nil unless object.supervisor_id.present?

      h.link_to object.supervisor_name, h.edit_supervisor_path(object.supervisor_id)
    end

    def assigned_to_transition_aged_youth?
      object.has_transition_aged_youth_cases? ? "Yes 🐛🦋" : "No"
    end

    def list_links_to_case_numbers
      links =
        object.casa_cases.map { |c|
          h.link_to c.case_number, c
        }

      h.safe_join links, ", "
    end

    def link_to_last_contact_made
      if object.most_recent_contact_case_id.present?
        h.link_to last_contact_made, h.casa_case_path(object.most_recent_contact_case_id)
      else
        last_contact_made
      end
    end

    def last_contact_made
      if object.most_recent_contact_occurred_at.nil?
        "None ❌"
      else
        object.most_recent_contact_occurred_at.strftime "%B %-e, %Y"
      end
    end
  end
end
