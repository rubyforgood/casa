desc "Transition youth who are now 14, run by heroku scheduler"
task transition_youth: :environment do
  puts "Updating casa cases..."
  CasaCase.should_transition.update_all(transition_aged_youth: true)
  puts "done."
end
