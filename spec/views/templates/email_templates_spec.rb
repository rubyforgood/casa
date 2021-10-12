require "rails_helper"


#We should log if no match

RSpec.describe "casa_admin_mailer", type: :view do
    it "Should validate that account_setup email template is valid" do
        file_path = Rails.root.join "app/views/casa_admin_mailer/account_setup.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end

    it "should validate that deactivation email template is valid" do
        file_path = Rails.root.join "app/views/casa_admin_mailer/deactivation.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end
end

RSpec.describe "devise", type: :view do
    it "Should validate that invitation_instruction email template is valid" do
        file_path = Rails.root.join "app/views/devise/mailer/invitation_instructions.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end

    it "should validate that reset_password_instructions email template is valid" do
        file_path = Rails.root.join "app/views/devise/mailer/reset_password_instructions.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end
end

RSpec.describe "supervisor_mailer", type: :view do
    it "Should validate that account_setup email template is valid" do
        file_path = Rails.root.join "app/views/supervisor_mailer/account_setup.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end

    it "should validate that weekly_digest email template is valid" do
        file_path = Rails.root.join "app/views/supervisor_mailer/weekly_digest.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end
end

RSpec.describe "user_mailer", type: :view do
    it "Should validate that password_changed_reminder email template is valid" do
        file_path = Rails.root.join "app/views/user_mailer/password_changed_reminder.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end
end

RSpec.describe "volunteer_mailer", type: :view do
    it "Should validate that account_setup email template is valid" do
        file_path = Rails.root.join "app/views/volunteer_mailer/account_setup.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end

    it "should validate that case_contacts_reminder email template is valid" do
        file_path = Rails.root.join "app/views/volunteer_mailer/case_contacts_reminder.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end

    it "should validate that court_report_reminder email template is valid" do
        file_path = Rails.root.join "app/views/volunteer_mailer/court_report_reminder.html.erb"
        file_content = File.read(file_path)

        tags_are_equal = validate_closing_tags_exist(file_content)

        expect(tags_are_equal).to be true 
    end
end