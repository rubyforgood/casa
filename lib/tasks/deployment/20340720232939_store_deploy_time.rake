namespace :after_party do
  desc "Deployment task: stores_the_time_of_the_latest_deploy_as_a_file"
  task store_deploy_time: :environment do
    puts "Running deploy task 'store_deploy_time'" unless Rails.env.test?

    status = with_captured_stdout { Rake::Task['after_party:status'].invoke }
    status_array = status.split("\n")

    # filter out store deploy time (this file) because recurring tasks always show as down
    status_array = status_array.reject { |line| line.include?("20340720232939  Store deploy time")}
    # look for other tasks that are down
    down_tasks = status_array.select { |line| line.starts_with?(" down")}

    if down_tasks.empty?
      puts("SHOULD BE CALLED BECAUSE NO DOWN TASKS #{down_tasks}")
      Health.instance.update_attribute(:latest_deploy_time, Time.now)
    end
  end
end

# Stole this from stack overflow
def with_captured_stdout
  original_stdout = $stdout  # capture previous value of $stdout
  $stdout = StringIO.new     # assign a string buffer to $stdout
  yield                      # perform the body of the user code
  $stdout.string             # return the contents of the string buffer
ensure
  $stdout = original_stdout  # restore $stdout to its previous value
end
