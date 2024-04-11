# This seed script populates the development DB with a data set whose size is dependent on the Rails environment.

# You can control the randomness of the data provided by FAKER and the Rails libraries via the DB_SEEDS_RANDOM_SEED environment variable.
# If you specify a number, that number will be used as the seed, so you can enforce consistent data across runs
#   with nondefault content.
# If you specify the string 'random' (e.g. `export DB_SEEDS_RANDOM_SEED=random`), a random seed will be assigned for you.
# If you don't specify anything, 0 will be used as the seed, ensuring consistent data across hosts and runs.

require 'faker'
require_relative 'seeds/casa_org_populator_presets'
require_relative 'seeds/db_populator'
require_relative '../lib/tasks/data_post_processors/case_contact_populator'
require_relative '../lib/tasks/data_post_processors/contact_type_populator'
require_relative '../lib/tasks/data_post_processors/sms_notification_event_populator'
require_relative '../lib/tasks/data_post_processors/contact_topic_populator'

class SeederMain
  attr_reader :db_populator, :rng

  def initialize
    random_seed = get_seed_specification
    @rng = Random.new(random_seed) # rng = random number generator
    @db_populator = DbPopulator.new(rng)
    Faker::Config.random = rng
    Faker::Config.locale = 'en-US' # only allow US phone numbers
  end

  def seed
    log 'NOTE: CASA seed does not delete anything anymore! Run rake db:seed:replant to delete everything and re-seed'
    log 'Creating the objects in the database...'
    db_populator.create_all_casa_admin('allcasaadmin@example.com')
    db_populator.create_all_casa_admin('all_casa_admin1@example.com')
    db_populator.create_all_casa_admin('admin1@example.com')
    db_populator.create_org(CasaOrgPopulatorPresets.for_environment.merge({ org_name: 'Prince George CASA' }))
    db_populator.create_org(CasaOrgPopulatorPresets.minimal_dataset_options)
    SmsNotificationEventPopulator.populate
    2.times do
      DbPopulator.new(rng, case_fourteen_years_old: true)
                 .create_org(CasaOrgPopulatorPresets.minimal_dataset_options)
    end

    post_process_data
    report_object_counts
    log "\nDone.\n\n"
  end

  private # -------------------------------------------------------------------------------------------------------

  # Used for reporting record counts after completion:
  def active_record_classes
    @active_record_classes ||= [
      AllCasaAdmin,
      CasaAdmin,
      CasaOrg,
      CasaCase,
      CaseContact,
      ContactTopic,
      ContactTopicAnswer,
      CaseCourtOrder,
      CaseAssignment,
      ChecklistItem,
      CourtDate,
      ContactType,
      ContactTypeGroup,
      HearingType,
      Judge,
      Language,
      LearningHourType,
      LearningHourTopic,
      MileageRate,
      Supervisor,
      SupervisorVolunteer,
      User,
      LearningHour,
      Volunteer
    ]
  end

  def post_process_data
    ContactTypePopulator.populate
    CaseContactPopulator.populate
    ContactTopicPopulator.populate
  end

  def get_seed_specification
    seed_environment_value = ENV['DB_SEEDS_RANDOM_SEED']

    if seed_environment_value.blank?
      seed = 0
      log "\nENV['DB_SEEDS_RANDOM_SEED'] not set to 'random' or a number; setting seed to 0.\n\n"
    elsif seed_environment_value.casecmp('random') == 0
      seed = Random.new_seed
      log "\n'random' specified in ENV['DB_SEEDS_RANDOM_SEED']; setting seed to randomly generated value #{seed}.\n\n"
    else
      seed = seed_environment_value.to_i
      log "\nUsing random seed #{seed} specified in ENV['DB_SEEDS_RANDOM_SEED'].\n\n"
    end
    seed
  end

  def report_object_counts
    log "\nRecords written to the DB:\n\nCount  Class Name\n-----  ----------\n\n"
    active_record_classes.each do |klass|
      log format('%5d  %s', klass.count, klass.name)
    end
    log "\n\nVolunteers, Supervisors and CasaAdmins are types of Users"
  end

  def log(message)
    return if Rails.env.test?

    puts message
  end
end

SeederMain.new.seed

load(Rails.root.join('db', 'seeds', 'emancipation_data.rb'))
begin
  load(Rails.root.join('db', 'seeds', 'emancipation_options_prune.rb'))
rescue StandardError => e
  puts "Caught error during db seed emancipation_options_prune, continuing. Message: #{e}"
end
