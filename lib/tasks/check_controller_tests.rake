namespace :test do
  desc "Check for controller tests in spec/controllers and fail if any are found"
  task check_controller_tests: :environment do
    controller_tests = Dir.glob("spec/controllers/**/*_spec.rb")
    if controller_tests.any?
      puts "controller tests should be in spec/requests"
      exit 1
    else
      puts "No controller tests found in spec/controllers"
    end
  end
end
