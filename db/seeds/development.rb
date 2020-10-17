require "faker"

# This seed script populates the development DB with minimal data.
# You can control the randomness of the data provided by FAKER via the FAKER_RANDOM_SEED environment variable.
# If you specify a number, that number will be used as the seed, so you can enforce consistent data across runs
#   with nondefault content.
# If you specify the string 'random' (i.e. `export FAKER_RANDOM_SEED=random`), a random seed will be assigned for you.
# If you don't specify anything, 0 will be used as the seed, ensuring consistent data across hosts and runs.

module DevelopmentSeederHelper

  CASA_CASE_COUNT = 2  # number of CASA cases to generate
  SEED_PASSWORD   = "123456"

  def case_number_generator
    # CINA-YY-XXXX
    years = ((DateTime.now.year - 20)..DateTime.now.year).to_a
    yy = years.sample.to_s[2..3]
    sequence_num = rand(1000..9999)
    "CINA-#{yy}-#{sequence_num}"
  end

  def logo
    @logo ||= CasaOrgLogo.new(
        url: "media/src/images/logo.png",
        alt_text: "CASA Logo",
        size: "70x38"
    )
  end
end


class PgCasaSeeder

  include DevelopmentSeederHelper

  attr_reader :casa_org, :volunteer

  def seed
    puts "Seeding PG Casa Organization"
    create_org
    create_users
    create_cases
    create_case_contacts
  end

  private

  def create_org
    @casa_org ||= CasaOrg.where(name: "Prince George CASA").first_or_create!(
        casa_org_logo: logo,
        display_name: "CASA / Prince George's County, MD",
        address: "6811 Kenilworth Avenue, Suite 402 Riverdale, MD 20737",
        footer_links: [
            ["https://pgcasa.org/contact/", "Contact Us"],
            ["https://pgcasa.org/subscribe-to-newsletter/", "Subscribe to newsletter"],
            ["https://www.givedirect.org/give/givefrm.asp?CID=4450", "Donate"]
        ]
    )
  end

  def create_users
    AllCasaAdmin.first_or_create!(
        email: "allcasaadmin@example.com",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )

    # seed users for all types [volunteer supervisor casa_admin]
    # volunteer users
    @volunteer = Volunteer.first_or_create!(
        casa_org: casa_org,
        display_name: Faker::Name.name,
        email: "volunteer1@example.com",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )

    # supervisor user
    pg_supervisor = Supervisor.first_or_create!(
        casa_org_id: casa_org.id,
        display_name: "Gloria O'Malley",
        email: "supervisor1@example.com",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )

    # Will fail silently if supervisor-volunteer record already exists.
    SupervisorVolunteer.create(supervisor: pg_supervisor, volunteer: volunteer)

    # casa_admin user
    CasaAdmin.first_or_create!(
        casa_org_id: casa_org.id,
        display_name: Faker::Name.name,
        email: "casa_admin1@example.com",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )
  end

  def create_cases
    # generate more CasaCases, add data, assign case to volunteer
    unless CasaCase.count > 0
      CASA_CASE_COUNT.times do |index|
        new_casa_case = CasaCase.create!(
            casa_org_id: casa_org.id,
            case_number: case_number_generator,
            transition_aged_youth: index % 2 == 0
        )
        CaseAssignment.create!(
            casa_case: new_casa_case,
            volunteer: volunteer
        )
      end
    end
  end

  def create_case_contacts
    # create CaseContact and associate with CasaCase, volunteer creator and include data
    CaseContact.first_or_create!(
        casa_case: casa_org.casa_cases.first,
        creator: volunteer,
        duration_minutes: 30,
        occurred_at: 2.months.ago,
        contact_types: ContactType.take(2),
        medium_type: CaseContact::CONTACT_MEDIUMS.sample,
        miles_driven: 5,
        want_driving_reimbursement: false,
        contact_made: true
    )
  end
end


class OtherCasaOrgSeeder

  include DevelopmentSeederHelper

  attr_reader :casa_org

  def seed
    puts "Seeding Other Organization"
    create_org
    create_users
  end

  private

  def create_org
    @casa_org ||= CasaOrg.where(name: "Other CASA org").first_or_create!(
        display_name: "CASA / Other County, MD",
        address: "123 Main St, Suite 101, Kennelwood, MD 01234",
        footer_links: [
            ["https://example.com/contact/", "Contact Us"],
            ["https://example.com/subscribe-to-newsletter/", "Subscribe to newsletter"]
        ]
    )
  end

  def create_users
    CasaAdmin.where(
        email: "other_casa_admin@example.com"
    ).first_or_create!(
        casa_org: casa_org,
        display_name: "Other Admin",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )

    Supervisor.where(
        email: "other.supervisor@example.com"
    ).first_or_create!(
        casa_org: casa_org,
        display_name: "Other Supervisor",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )

    Volunteer.where(
        email: "other.volunteer@example.com"
    ).first_or_create!(
        casa_org: casa_org,
        display_name: "Other Volunteer",
        password: SEED_PASSWORD,
        password_confirmation: SEED_PASSWORD
    )
  end
end


ACTIVE_RECORD_CLASSES = [
    CasaOrg,
    CasaCase,
    User,
    Volunteer,
    Supervisor,
    CasaAdmin,
    AllCasaAdmin,
    SupervisorVolunteer,
    CaseAssignment,
    ContactType,
    ContactTypeGroup,
    CaseContact,
]

def destroy_all
  # Order is important here; CaseContact must be destroyed before the User that created it.
  # The User is destroyed as a result of destroying the CasaOrg.
  [CaseContact, CasaOrg, AllCasaAdmin, ContactType].each { |klass| klass.destroy_all }

  non_empty_classes = ACTIVE_RECORD_CLASSES.select { |klass| klass.count > 0 }
  unless non_empty_classes.empty?
    raise "destroy_all did not result in the following classes being empty: #{non_empty_classes.join(', ')}"
  end
end

def after_party
  Rake::Task["after_party:run"].invoke
end

def process_faker_seed_specification
  seed_environment_value = ENV['FAKER_RANDOM_SEED']

  if seed_environment_value.blank?
    seed = 0
    puts "\nENV['FAKER_RANDOM_SEED'] not set to 'random' or a number; setting seed to 0.\n\n"
  elsif seed_environment_value.casecmp('random') == 0
    seed = Random.new_seed
    puts "\n'random' specified in ENV['FAKER_RANDOM_SEED']; setting seed to randomly generated value #{seed}.\n\n"
  else
    seed = seed_environment_value.to_i
    puts "\nUsing random seed #{seed} specified in ENV['FAKER_RANDOM_SEED'].\n\n"
  end

  Faker::Config.random = Random.new(seed)
end


def report_object_counts
  puts "\nRecords written to the DB:\n\nCount  Class Name\n-----  ----------\n\n"
  ACTIVE_RECORD_CLASSES.each do |klass|
    puts "%5d  %s" % [klass.count, klass.name]
  end
end

def seed
  process_faker_seed_specification
  destroy_all
  after_party
  PgCasaSeeder.new.seed
  OtherCasaOrgSeeder.new.seed
  report_object_counts
  puts "\nDone.\n\n"
end

seed
