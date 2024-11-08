require "rails_helper"

RSpec.shared_examples "compares opening and closing tags" do
  include TemplateHelper

  it "validates html tags" do
    file_content = File.read(Rails.root.join(file_path))
    tags_are_equal = validate_closing_tags_exist(file_content)

    expect(tags_are_equal).to be true
  end
end

RSpec.describe "casa_admin_mailer", type: :view do
  describe "should validate that account_setup email template is valid" do
    let(:file_path) { "app/views/casa_admin_mailer/account_setup.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that deactivation email template is valid" do
    let(:file_path) { "app/views/casa_admin_mailer/deactivation.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end
end

RSpec.describe "devise", type: :view do
  describe "should validate that confirmation_instructions email template is valid" do
    let(:file_path) { "app/views/devise/mailer/confirmation_instructions.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that email_changed email template is valid" do
    let(:file_path) { "app/views/devise/mailer/email_changed.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that invitation_instruction email template is valid" do
    let(:file_path) { "app/views/devise/mailer/invitation_instructions.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that password_change email template is valid" do
    let(:file_path) { "app/views/devise/mailer/password_change.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that reset_password_instructions email template is valid" do
    let(:file_path) { "app/views/devise/mailer/reset_password_instructions.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that unlock_instructions email template is valid" do
    let(:file_path) { "app/views/devise/mailer/unlock_instructions.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end
end

RSpec.describe "supervisor_mailer", type: :view do
  describe "should validate that account_setup email template is valid" do
    let(:file_path) { "app/views/supervisor_mailer/account_setup.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that weekly_digest email template is valid" do
    let(:file_path) { "app/views/supervisor_mailer/weekly_digest.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end
end

RSpec.describe "user_mailer", type: :view do
  describe "should validate that password_changed_reminder email template is valid" do
    let(:file_path) { "app/views/user_mailer/password_changed_reminder.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end
end

RSpec.describe "volunteer_mailer", type: :view do
  describe "should validate that account_setup email template is valid" do
    let(:file_path) { "app/views/volunteer_mailer/account_setup.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that case_contacts_reminder email template is valid" do
    let(:file_path) { "app/views/volunteer_mailer/case_contacts_reminder.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end

  describe "should validate that court_report_reminder email template is valid" do
    let(:file_path) { "app/views/volunteer_mailer/court_report_reminder.html.erb" }

    it_behaves_like "compares opening and closing tags"
  end
end
