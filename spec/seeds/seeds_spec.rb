require "rails_helper"
require "rake"

RSpec.describe "Seeds" do
  ["development", "qa", "staging"].each do |environment|
    describe "for environment: #{environment}" do
      before do
        Rails.application.load_tasks
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(environment))
      end

      it 'executes without raising an exception' do
        expect { ActiveRecord::Tasks::DatabaseTasks.load_seed }.not_to raise_error
      end
    end
  end
end
