desc "Demo task for proving the whenever gem"
task demo_task: :environment do
  p "hello #{Time.now}"
end
