# This seed script populates the development DB with a data set whose size is dependent on the Rails environment.

# You can control the randomness of the data provided by FAKER and the Rails libraries via the DB_SEEDS_RANDOM_SEED environment variable.
# If you specify a number, that number will be used as the seed, so you can enforce consistent data across runs
#   with nondefault content.
# If you specify the string 'random' (e.g. `export DB_SEEDS_RANDOM_SEED=random`), a random seed will be assigned for you.
# If you don't specify anything, 0 will be used as the seed, ensuring consistent data across hosts and runs.

require "faker"
require_relative "seeds/casa_org_populator_presets"
require_relative "seeds/db_populator"
require_relative "../lib/tasks/data_post_processors/case_contact_populator"
require_relative "../lib/tasks/data_post_processors/contact_type_populator"

class SeederMain
  attr_reader :db_populator, :rng

  def initialize
    random_seed = get_seed_specification
    @rng = Random.new(random_seed) # rng = random number generator
    @db_populator = DbPopulator.new(rng)
    Faker::Config.random = rng
  end

  def seed
    puts "Erasing all objects from the data base..."
    destroy_all

    puts "Creating the objects in the data base..."
    db_populator.create_all_casa_admin("allcasaadmin@example.com")
    db_populator.create_all_casa_admin("all_casa_admin1@example.com")
    # TODO - always create at least 2 CASAs with different-looking data so we can find cross-CASA bugs
    db_populator.create_org(CasaOrgPopulatorPresets.for_environment.merge({org_name: "Prince George CASA"}))
    db_populator.create_org(CasaOrgPopulatorPresets.minimal_dataset_options)

    post_process_data

    report_object_counts
    puts "\nDone.\n\n"
  end

  private # -------------------------------------------------------------------------------------------------------

  # Used for reporting record counts after completion:
  def active_record_classes
    @active_record_classes ||= [
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
      CaseContact
    ]
  end

  def destroy_all
    # Order is important here; CaseContact must be destroyed before the User that created it.
    # The User is destroyed as a result of destroying the CasaOrg.
    [SupervisorVolunteer, CaseContact, CasaOrg, AllCasaAdmin, ContactTypeGroup, ContactType].each { |klass| klass.destroy_all }
    non_empty_classes = active_record_classes.select { |klass| klass.count > 0 }
    if non_empty_classes.any?
      raise "destroy_all did not result in the following classes being empty: #{non_empty_classes.join(", ")}"
    end
  end

  def post_process_data
    ContactTypePopulator.populate
    CaseContactPopulator.populate
  end

  def get_seed_specification
    seed_environment_value = ENV["DB_SEEDS_RANDOM_SEED"]

    if seed_environment_value.blank?
      seed = 0
      puts "\nENV['DB_SEEDS_RANDOM_SEED'] not set to 'random' or a number; setting seed to 0.\n\n"
    elsif seed_environment_value.casecmp("random") == 0
      seed = Random.new_seed
      puts "\n'random' specified in ENV['DB_SEEDS_RANDOM_SEED']; setting seed to randomly generated value #{seed}.\n\n"
    else
      seed = seed_environment_value.to_i
      puts "\nUsing random seed #{seed} specified in ENV['DB_SEEDS_RANDOM_SEED'].\n\n"
    end
    seed
  end

  def report_object_counts
    puts "\nRecords written to the DB:\n\nCount  Class Name\n-----  ----------\n\n"
    active_record_classes.each do |klass|
      puts "%5d  %s" % [klass.count, klass.name]
    end
  end
end

SeederMain.new.seed
