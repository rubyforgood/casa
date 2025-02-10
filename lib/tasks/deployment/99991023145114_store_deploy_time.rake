namespace :after_party do
  desc "Deployment task: stores_the_time_of_the_latest_deploy_as_a_file"
  task store_deploy_time: :environment do
    puts "Running deploy task 'store_deploy_time'" unless Rails.env.test?
    pending_files = AfterParty::TaskRecorder.pending_files

    down_tasks = pending_files.reject { |item| item.task_name == "store_deploy_time" }
    if down_tasks.empty?
      Health.instance.update_attribute(:latest_deploy_time, Time.now)
    else
      puts("failed tasks found, latest_deploy_time will not be updated!")
    end
  end
end
