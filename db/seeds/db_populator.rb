# Called by the seeding process to create data with a specified random number generator.
# There is a 1 in 30 probability that a Volunteer will be inactive when created.
# There is no instance of a volunteer who was previously assigned a case being inactivated.
# Email addresses generated will be globally unique across all orgs.

class DbPopulator
  SEED_PASSWORD = "12345678"
  WORD_LENGTH_TUNING = 10
  LINE_BREAK_TUNING = 5
  PREFIX_OPTIONS = ("A".ord.."Z".ord).to_a.map(&:chr)

  attr_reader :rng

  # Public Methods

  # Pass an instance of Random for Faker and Ruby `rand` and sample` calls.
  def initialize(random_instance, case_fourteen_years_old: false)
    @rng = random_instance
    @casa_org_counter = 0
    @case_number_sequence = 1000
    @case_fourteen_years_old = case_fourteen_years_old
  end

  def create_all_casa_admin(email)
    return if AllCasaAdmin.find_by(email: email)
    AllCasaAdmin.create!(email: email, password: SEED_PASSWORD, password_confirmation: SEED_PASSWORD)
  end

  def create_org(options)
    @casa_org_counter += 1

    options.org_name ||= "CASA Organization ##{@casa_org_counter}"
    CasaOrg.find_or_create_by!(name: options.org_name) { |org|
      org.name = options.org_name
      org.display_name = options.org_name
      org.address = Faker::Address.full_address
      org.footer_links = [
        ["https://example.org/contact/", "Contact Us"],
        ["https://example.org/subscribe-to-newsletter/", "Subscribe to newsletter"],
        ["https://www.example.org/give/givefrm.asp?CID=4450", "Donate"]
      ]
      org.logo.attach(io: File.open(CasaOrg::CASA_DEFAULT_LOGO), filename: CasaOrg::CASA_DEFAULT_LOGO.basename.to_s)
    }
  end

  # Create 2 judges for each casa_org.
  def create_judges(casa_org)
    2.times { Judge.create(name: Faker::Name.name, casa_org: casa_org) }
  end

  # Creates 3 users, 1 each for [Volunteer, Supervisor, CasaAdmin].
  # For org's after the first one created, adds an org number to the email address so that they will be globally unique
  def create_users(casa_org, options)
    # Generate email address; for orgs only after first org, and org number would be added, e.g.:
    # Org #1: volunteer1@example.com
    # Org #2: volunteer2-1@example.com
    email = ->(klass, n) do
      org_fragment = (@casa_org_counter > 1) ? "#{@casa_org_counter}-" : ""
      klass.name.underscore + org_fragment + n.to_s + "@example.com"
    end

    create_users_of_type = ->(klass, count) do
      (1..count).each do |n|
        current_email = email.call(klass, n)
        attributes = {
          casa_org: casa_org,
          email: current_email,
          password: SEED_PASSWORD,
          password_confirmation: SEED_PASSWORD,
          display_name: Faker::Name.name,
          phone_number: Faker::PhoneNumber.cell_phone_in_e164,
          active: true,
          confirmed_at: Time.now
        }
        # Approximately 1 out of 30 volunteers should be set to inactive.
        if klass == Volunteer && rng.rand(30) == 0
          attributes[:active] = false
        end
        unless klass.find_by(email: current_email)
          klass.create!(attributes)
        end
      end
    end

    create_users_of_type.call(CasaAdmin, options.casa_admin_count)
    create_users_of_type.call(Supervisor, options.supervisor_count)
    create_users_of_type.call(Volunteer, options.volunteer_count)
    supervisors = Supervisor.all.to_a
    Volunteer.find_each { |v| v.supervisor = supervisors.sample(random: rng) }
  end

  # Create other duties (Volunteer only)
  # Increment other_duties_counter by 1 each time other duty is created
  # Print out statement that indicates number of other duties created

  def create_other_duties
    Volunteer.find_each do |v|
      2.times {
        OtherDuty.create!(
          creator_id: v.id,
          creator_type: "Volunteer",
          occurred_at: Faker::Date.between(from: 2.days.ago, to: Date.today),
          duration_minutes: rand(5..180),
          notes: Faker::Lorem.sentence
        )
      }
    end
  end

  def create_case_contacts(casa_case)
    draft_statuses = %w[started details notes expenses]

    case_contact_statuses = Array.new(random_zero_one_count, draft_statuses.sample(random: rng)) +
      Array.new(random_case_contact_count, "active")

    case_contact_statuses.shuffle(random: rng).each do |status|
      create_case_contact(casa_case, status:)
    end
  end

  def create_case_contact(casa_case, status: "active")
    params = base_case_contact_params(casa_case, status)

    status_modifications = {
      "started" => {want_driving_reimbursement: false, draft_case_ids: [], medium_type: nil, occurred_at: nil, duration_minutes: nil, notes: nil, miles_driven: 0},
      "details" => {want_driving_reimbursement: false, notes: nil, miles_driven: 0},
      "notes" => {want_driving_reimbursement: false, miles_driven: 0},
      "expenses" => {want_driving_reimbursement: true}
    }

    params.merge!(status_modifications[status]) unless status == "active"
    CaseContact.create!(params)
  end

  def create_cases(casa_org, options)
    ContactTypePopulator.populate
    options.case_count.times do |index|
      case_number = generate_case_number
      court_date = generate_court_date
      court_report_submitted = index.even?

      new_casa_case = CasaCase.find_by(case_number: case_number)
      birth_month_year_youth = @case_fourteen_years_old ? ((Date.today - 18.year)..(Date.today - CasaCase::TRANSITION_AGE.year)).to_a.sample : ((Date.today - 18.year)..(Date.today - 1.year)).to_a.sample
      new_casa_case ||= CasaCase.find_or_create_by!(
        casa_org_id: casa_org.id,
        case_number: case_number,
        court_report_submitted_at: court_report_submitted ? Date.today : nil,
        court_report_status: court_report_submitted ? :submitted : :not_submitted,
        birth_month_year_youth: birth_month_year_youth,
        date_in_care: Date.today - (rand * 1500)
      )
      new_court_date = CourtDate.find_or_create_by!(
        casa_case: new_casa_case,
        court_report_due_date: court_date + 1.month,
        date: court_date
      )

      volunteer = new_casa_case.casa_org.volunteers.active.sample(random: rng) ||
        new_casa_case.casa_org.volunteers.active.first ||
        Volunteer.create!(
          casa_org: new_casa_case.casa_org,
          email: "#{SecureRandom.hex(10)}@example.com",
          password: SEED_PASSWORD,
          display_name: "active volunteer"
        )
      CaseAssignment.find_or_create_by!(casa_case: new_casa_case, volunteer: volunteer)

      random_court_order_count.times do
        CaseCourtOrder.create!(
          casa_case_id: new_casa_case.id,
          court_date: new_court_date,
          text: order_choices.sample(random: rng),
          implementation_status: CaseCourtOrder::IMPLEMENTATION_STATUSES.values.sample(random: rng)
        )
      end

      random_zero_one_count.times do |index|
        CourtDate.create!(
          casa_case_id: new_casa_case.id,
          date: Date.today + 5.weeks
        )
      end

      random_past_court_date_count.times do |index|
        CourtDate.create!(
          casa_case_id: new_casa_case.id,
          date: Date.today - (index + 1).weeks
        )
      end

      create_case_contacts(new_casa_case)

      # guarantee at least one case contact before and after most recent past court date
      if most_recent_past_court_date(new_casa_case.id)
        if !case_contact_before_last_court_date?(new_casa_case.id, most_recent_past_court_date(new_casa_case.id))
          new_case_contact = create_case_contact(new_casa_case)
          new_case_contact.occurred_at = most_recent_past_court_date(new_casa_case.id) - 24.hours
          new_case_contact.save!
        end

        if !case_contact_after_last_court_date?(new_casa_case.id, most_recent_past_court_date(new_casa_case.id))
          new_case_contact = create_case_contact(new_casa_case)
          new_case_contact.occurred_at = most_recent_past_court_date(new_casa_case.id) + 24.hours
          new_case_contact.save!
        end
      end

      # guarantee at least one transition aged youth case to "volunteer1"
      volunteer1 = Volunteer.find_by(email: "volunteer1@example.com")
      if volunteer1.casa_cases.where(birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago).blank?
        rand(1..3).times do
          birth_month_year_youth = ((Date.today - 18.year)..(Date.today - CasaCase::TRANSITION_AGE.year)).to_a.sample
          new_casa_case = volunteer1.casa_cases.find_or_create_by!(
            casa_org_id: volunteer1.casa_org.id,
            case_number: generate_case_number,
            court_report_submitted_at: court_report_submitted ? Date.today : nil,
            court_report_status: court_report_submitted ? :submitted : :not_submitted,
            birth_month_year_youth: birth_month_year_youth
          )
          CourtDate.find_or_create_by!(
            casa_case: new_casa_case,
            court_report_due_date: court_date + 1.month,
            date: court_date
          )
        end
      end
    end
  end

  def create_hearing_types(casa_org)
    active_hearing_type_names = [
      "emergency hearing",
      "trial on the merits",
      "scheduling conference",
      "uncontested hearing",
      "pendente lite hearing",
      "pretrial conference"
    ]
    inactive_hearing_type_names = [
      "deprecated hearing"
    ]
    active_hearing_type_names.each do |hearing_type_name|
      HearingType.find_or_create_by!(
        casa_org_id: casa_org.id,
        name: hearing_type_name,
        active: true
      )
    end
    inactive_hearing_type_names.each do |hearing_type_name|
      HearingType.find_or_create_by!(
        casa_org_id: casa_org.id,
        name: hearing_type_name,
        active: false
      )
    end
  end

  def create_checklist_items
    checklist_item_categories = [
      "Education/Vocation",
      "Placement",
      "Category 3"
    ]
    checklist_item_descriptions = [
      "checklist item description 1",
      "checklist item description 2",
      "checklist item description 3"
    ]
    mandatory_options = [true, false]
    half_of_the_hearing_types = HearingType.all.slice(0, HearingType.all.length / 2)
    half_of_the_hearing_types.each do |hearing_type|
      ChecklistItem.create(
        hearing_type_id: hearing_type.id,
        description: checklist_item_descriptions.sample,
        category: checklist_item_categories.sample,
        mandatory: mandatory_options.sample
      )
      hearing_type.update_attribute(:checklist_updated_date, "Updated #{Time.new.strftime("%m/%d/%Y")}")
    end
  end

  def create_languages(casa_org)
    create_language("Spanish", casa_org)
    create_language("Vietnamese", casa_org)
    create_language("French", casa_org)
    create_language("Chinese Cantonese", casa_org)
    create_language("ASL", casa_org)
    create_language("Other", casa_org)
  end

  def create_language(name, casa_org)
    Language.find_or_create_by!(name: name, casa_org: casa_org)
  end

  def create_mileage_rates(casa_org)
    attempt_count = 5
    i = 0

    while i < attempt_count
      begin
        MileageRate.create!({
          amount: Faker::Number.between(from: 0.0, to: 1.0).round(2),
          effective_date: Faker::Date.backward(days: 700),
          is_active: true,
          casa_org_id: casa_org.id
        })
      rescue ActiveRecord::RecordInvalid
        attempt_count += 1
      end

      i += 1
    end
  end

  def create_learning_hour_types(casa_org)
    learning_types = %w[book movie webinar conference other]

    learning_types.each do |learning_type|
      learning_hour_type = casa_org.learning_hour_types.new(name: learning_type.capitalize)
      learning_hour_type.position = 99 if learning_type == "other"
      learning_hour_type.save
    end
  end

  def create_learning_hour_topics(casa_org)
    learning_topics = %w[cases reimbursements court_reports]
    learning_topics.each do |learning_topic|
      learning_hour_topic = casa_org.learning_hour_topics.new(name: learning_topic.humanize.capitalize)
      learning_hour_topic.save
    end
  end

  def create_learning_hours(casa_org)
    casa_org.volunteers.each do |user|
      [1, 2, 3].sample.times do
        learning_hour_topic = casa_org.learning_hour_topics.sample
        learning_hour_type = casa_org.learning_hour_types.sample
        # randomize between 30 to 180 minutes
        duration_minutes = (2..12).to_a.sample * 15
        duration_hours = duration_minutes / 60
        duration_minutes %= 60
        occurred_at = Time.current - (1..7).to_a.sample.days
        LearningHour.create(
          user:,
          learning_hour_type:,
          name: "#{learning_hour_type.name} on #{learning_hour_topic.name}",
          duration_hours:,
          duration_minutes:,
          occurred_at:,
          learning_hour_topic:
        )
      end
    end
  end

  private # -------------------------------------------------------------------------------------------------------

  def most_recent_past_court_date(casa_case_id)
    CourtDate.where(
      "date < ? AND casa_case_id = ?",
      Date.today,
      casa_case_id
    ).order(date: :desc).first&.date
  end

  def case_contact_before_last_court_date?(casa_case_id, date)
    CaseContact.where(
      "occurred_at < ? AND casa_case_id = ?",
      date,
      casa_case_id
    ).any?
  end

  def case_contact_after_last_court_date?(case_case_id, date)
    CaseContact.where(
      "occurred_at > ? AND casa_case_id = ?",
      date,
      case_case_id
    ).any?
  end

  def order_choices
    [
      "Limited guardianship of the children for medical and educational purposes to [name] shall be rescinded;",
      "The children shall remain children in need of assistance (cina), under the jurisdiction of the juvenile court, and shall remain committed to the department of health and human services/child welfare services, for continued placement on a trial home visit with [NAME]",
      "The youth shall continue to participate in educational tutoring, under the direction of the department;",
      "The youth shall continue to participate in family therapy with [name], under the direction of the department;",
      "The permanency plan for all the children of reunification is reaffirmed;",
      "Visitation between the youth and the father shall be unsupervised, minimum once weekly, in the community or at his home, and may include overnights when he has the appropriate space for the children to sleep, under the direction of the department;",
      "Youth shall continue to participate in individual therapy, under the direction of the department;",
      "The youth shall continue to maintain stable employment;",
      "The youth shall maintain appropriate housing while working towards obtaining housing that can accommodate all of the children being reunified, and make home available for inspection, under the direction of the department;",
      "The youth shall participate in case management services, under the direction of the department;",
      "The youth shall participate in mental health treatment and medication management, under the direction of the department;"
    ]
  end

  def transition_aged_youth?(birth_month_year_youth)
    (Date.today - birth_month_year_youth).days.in_years > CasaCase::TRANSITION_AGE
  end

  def base_case_contact_params(casa_case, status)
    {
      casa_case: casa_case,
      creator: casa_case.volunteers.sample(random: rng),
      duration_minutes: likely_contact_durations.sample(random: rng),
      occurred_at: rng.rand(0..6).months.ago,
      contact_types: ContactType.all.sample(2, random: rng),
      medium_type: CaseContact::CONTACT_MEDIUMS.sample(random: rng),
      miles_driven: rng.rand(5..40),
      want_driving_reimbursement: random_true_false,
      contact_made: random_true_false,
      notes: note_generator,
      status: status,
      draft_case_ids: [casa_case&.id]
    }
  end

  def random_case_contact_count
    @random_case_contact_counts ||= [0, 1, 2, 2, 2, 3, 3, 3, 11, 11, 11]
    @random_case_contact_counts.sample(random: rng)
  end

  def random_past_court_date_count
    @random_past_court_date_counts ||= [0, 2, 3, 4, 5]
    @random_past_court_date_counts.sample(random: rng)
  end

  def random_zero_one_count
    @random_zero_one_count ||= [0, 1]
    @random_zero_one_count.sample(random: rng)
  end

  def random_court_order_count
    @random_court_order_counts ||= [0, 3, 5, 10]
    @random_court_order_counts.sample(random: rng)
  end

  def likely_contact_durations
    @likely_contact_durations ||= [15, 30, 60, 75, 4 * 60, 6 * 60]
  end

  def note_generator
    paragraph_count = Random.rand(6)
    (0..paragraph_count).map { |index|
      Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 20)
    }.join("\n\n")
  end

  def generate_case_number
    # CINA-YY-XXXX
    years = ((DateTime.now.year - 20)..DateTime.now.year).to_a
    yy = years.sample(random: rng).to_s[2..3]
    @case_number_sequence += 1
    "CINA-#{yy}-#{@case_number_sequence}"
  end

  def generate_court_date
    ((Date.today + 1.month)..(Date.today + 5.months)).to_a.sample
  end

  def random_true_false
    @true_false_array ||= [true, false]
    @true_false_array.sample(random: rng)
  end
end
