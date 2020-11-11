namespace :after_party do
  desc "Deployment task: populate_prince_george_casa_org_details"
  task populate_prince_george_casa_org_details: :environment do
    puts "Running deploy task 'populate_prince_george_casa_org_details'" unless Rails.env.test?

    # Seed existing PG CASA logo/display details for production
    # (Okay to run on dev too - will just duplicate seed data)
    casa_org = CasaOrg.find_or_create_by!(name: "Prince George CASA")

    logo = casa_org.casa_org_logo || casa_org.build_casa_org_logo
    logo.update!(
      url: "media/src/images/logo.png",
      alt_text: "CASA Logo",
      size: "70x38"
    )

    casa_org.update!(casa_org_logo: logo,
                     display_name: "CASA / Prince George's County, MD",
                     address: "6811 Kenilworth Avenue, Suite 402 Riverdale, MD 20737",
                     footer_links: [
                       ["https://pgcasa.org/contact/", "Contact Us"],
                       ["https://pgcasa.org/subscribe-to-newsletter/", "Subscribe to newsletter"],
                       ["https://www.givedirect.org/give/givefrm.asp?CID=4450", "Donate"]
                     ])
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
