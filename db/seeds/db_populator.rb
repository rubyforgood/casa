# Called by the seeding process to create data with a specified random number generator.
# There is a 1 in 30 probability that a Volunteer will be inactive when created.
# There is no instance of a volunteer who was previously assigned a case being inactivated.
# Email addresses generated will be globally unique across all orgs.

class DbPopulator
  SEED_PASSWORD = "123456"
  WORD_LENGTH_TUNING = 10

  attr_reader :rng

  # Public Methods

  # Pass an instance of Random for Faker and Ruby `rand` and sample` calls.
  def initialize(random_instance)
    @rng = random_instance
    @casa_org_counter = 0
    @case_number_sequence = 1000
  end

  def create_all_casa_admin(email = "allcasaadmin@example.com")
    AllCasaAdmin.create!(email: email, password: SEED_PASSWORD, password_confirmation: SEED_PASSWORD)
  end

  # See CasaOrgPopulatorPresets for the content of the options hash.
  def create_org(options_hash)
    options = OpenStruct.new(options_hash)
    @casa_org_counter += 1

    options.org_name ||= "CASA Organization ##{@casa_org_counter}"
    casa_org = CasaOrg.find_or_create_by!(name: options.org_name) { |org|
      org.name = options.org_name
      org.display_name = options.org_name
      org.casa_org_logo = logo
      org.address = Faker::Address.full_address
      org.footer_links = [
        ["https://example.org/contact/", "Contact Us"],
        ["https://example.org/subscribe-to-newsletter/", "Subscribe to newsletter"],
        ["https://www.example.org/give/givefrm.asp?CID=4450", "Donate"]
      ]
    }

    create_users(casa_org, options)
    create_cases(casa_org, options)
    casa_org
  end

  private # -------------------------------------------------------------------------------------------------------

  # Creates 3 users, 1 each for [Volunteer, Supervisor, CasaAdmin].
  # For org's after the first one created, adds an org number to the email address so that they will be globally unique
  def create_users(casa_org, options)
    # Generate email address; for orgs only after first org, and org number would be added, e.g.:
    # Org #1: volunteer1@example.com
    # Org #2: volunteer2-1@example.com
    email = ->(klass, n) do
      org_fragment = @casa_org_counter > 1 ? "#{@casa_org_counter}-" : ""
      klass.name.underscore + org_fragment + n.to_s + "@example.com"
    end

    create_users_of_type = ->(klass, count) do
      (1..count).each do |n|
        attributes = {
          casa_org: casa_org,
          email: email.call(klass, n),
          display_name: Faker::Name.name,
          password: SEED_PASSWORD,
          password_confirmation: SEED_PASSWORD,
          active: true
        }
        # Approximately 1 out of 30 volunteers should be set to inactive.
        if klass == Volunteer && rng.rand(30) == 0
          attributes[:active] = false
        end
        klass.create!(attributes)
      end
    end

    create_users_of_type.call(CasaAdmin, options.casa_admin_count)
    create_users_of_type.call(Supervisor, options.supervisor_count)
    create_users_of_type.call(Volunteer, options.volunteer_count)
    supervisors = Supervisor.all.to_a
    Volunteer.all.each { |v| v.supervisor = supervisors.sample(random: rng) }
  end

  def generate_case_number
    # CINA-YY-XXXX
    years = ((DateTime.now.year - 20)..DateTime.now.year).to_a
    yy = years.sample(random: rng).to_s[2..3]
    @case_number_sequence += 1
    "CINA-#{yy}-#{@case_number_sequence}"
  end

  def random_true_false
    @true_false_array ||= [true, false]
    @true_false_array.sample(random: rng)
  end

  def random_case_contact_count
    @random_case_contact_counts ||= [0, 1, 2, 2, 2, 3, 3, 3, 11, 11, 11]
    @random_case_contact_counts.sample(random: rng)
  end

  def likely_contact_durations
    @likely_contact_durations ||= [15, 30, 60, 75, 4 * 60, 6 * 60]
  end

  def logo
    @logo ||= CasaOrgLogo.new(url: "media/src/images/logo.png", alt_text: "CASA Logo", size: "70x38")
  end

  def note_generator(note_length)
    available_chars = [("a".."z"), ("A".."Z"), (1..9), [" "] * WORD_LENGTH_TUNING].map(&:to_a).flatten.map(&:to_s)
    (0...note_length).map { available_chars[rng.rand(available_chars.length)] }.join
  end

  def create_case_contact(casa_case)
    CaseContact.create!(
      casa_case: casa_case,
      creator: casa_case.volunteers.sample(random: rng),
      duration_minutes: likely_contact_durations.sample(random: rng),
      occurred_at: rng.rand(0..6).months.ago,
      contact_types: ContactType.all.sample(2, random: rng),
      medium_type: CaseContact::CONTACT_MEDIUMS.sample(random: rng),
      miles_driven: rng.rand(5..40),
      want_driving_reimbursement: random_true_false,
      contact_made: random_true_false,
      notes: note_generator(rng.rand(0..4000))
    )
  end

  def create_cases(casa_org, options)
    volunteers = Volunteer.where(active: true).to_a
    options.case_count.times do
      new_casa_case = CasaCase.create!(
        casa_org_id: casa_org.id,
        case_number: generate_case_number,
        transition_aged_youth: random_true_false
      )
      casa_org_volunteers = volunteers.select { |volunteer| volunteer.casa_org_id == casa_org.id }
      CaseAssignment.create!(casa_case: new_casa_case, volunteer: casa_org_volunteers.sample(random: rng))

      random_case_contact_count.times do
        create_case_contact(new_casa_case)
      end
    end
  end
end
