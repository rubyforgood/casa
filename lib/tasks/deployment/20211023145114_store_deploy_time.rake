namespace :after_party do
  desc 'Deployment task: stores_the_time_of_the_latest_deploy_as_a_file'
  task store_deploy_time: :environment do
    puts "Running deploy task 'store_deploy_time'"

    FileUtils.mkdir_p Rails.root.join('tmp')

    File.open(Rails.root.join('tmp', 'deploy_time.json'),'w') do |f|
      f.write({latest_deploy_time: Time.now.utc.iso8601}.to_json)
    end
  end
end
