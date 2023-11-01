namespace :after_party do
  desc "Deployment task: stores_the_time_of_the_latest_deploy_as_a_file"
  task store_deploy_time: :environment do
    puts "Running deploy task 'store_deploy_time'" unless Rails.env.test?

    Health.instance.update_attribute(:latest_deploy_time, Time.now)
  end
end
