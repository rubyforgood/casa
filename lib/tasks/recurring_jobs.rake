namespace :recurring do
  task init: :environment do
    ExampleRecurringTask.schedule!
  end
end
