namespace :recurring do
  task init: :environment do
    if Rails.env.qa?
      puts "re-seeding QA!"
      ReSeedQa.schedule!
    end
  end
end