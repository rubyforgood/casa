class CaseContactsContactDates
  attr_reader :case_contacts, :filtered_columns

  def initialize(interviewees)
    @interviewees = interviewees
  end

  def contact_dates_details
    contact_dates_as_hash = aggregate_contact_dates(@interviewees)
    contact_dates_as_hash.map do |type, dates|
      {
        name: "Names of persons involved, starting with the child's name",
        type: type,
        dates: dates.join(", ")
      }
    end
  end

  private

  def aggregate_contact_dates(people)
    contact_dates = Hash.new([])

    people.each do |person|
      contact_type = person.contact_type.name
      date_with_format = format_date_contact_attempt(person.case_contact)

      contact_dates[contact_type] << (date_with_format) && next if contact_dates.key?(contact_type)

      contact_dates[contact_type] = [date_with_format]
    end

    sort_dates(contact_dates)
  end

  def sort_dates(contact_dates)
    contact_dates.each_value do |dates|
      next if dates.size <= 1

      dates.sort! { |first_date, second_date| first_date.delete("*") <=> second_date.delete("*") }
    end
  end
end
