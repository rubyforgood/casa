module CasaCasesHelper
	def render_eligible_volunteers(volunteer)
		if @casa_case.volunteers.exclude?(volunteer)
			content_tag(:option, "#{volunteer.display_name}", {value: "#{volunteer.id}"})
		end
	end
end