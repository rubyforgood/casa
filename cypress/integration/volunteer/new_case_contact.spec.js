  // TODO - fix flakey spec ref: https://github.com/rubyforgood/casa/issues/2550#issuecomment-943474980
const faker = require("faker");

context.skip("Logging into cypress as a volunteer", () => {
  beforeEach(() => {
    cy.visit("0.0.0.0:4040");
    cy.loginAsVolunteer();
  });
  it("should create a new case contact", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.contains("Case Contacts").click();
    cy.contains("New Case Contact").click();
    cy.get("h1").contains("New Case Contact");

    cy.get("#case_contact_contact_type_1").check();   // 'Youth' contact type
    cy.get("#case_contact_contact_type_3").check();   // 'Parent' contact type
    cy.get("#case_contact_contact_made_true").check();  // 'Contact made'
    cy.get("#case_contact_medium_type").select("In Person");
    cy.get("#casa-contact-duration-minutes-display").type('15');
    cy.contains("Submit").click();
    cy.contains("Case contact was successfully created.").should("exist");
  });
  it("should create a new case contact with a note", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.contains("Case Contacts").click();
    cy.contains("New Case Contact").click();

    cy.get("#case_contact_contact_type_2").check();     // 'Supervisor' contact type
    cy.get("#case_contact_contact_made_false").check(); // 'No contact made'
    cy.get("#case_contact_medium_type").select("Letter");
    cy.get("#casa-contact-duration-minutes-display").type('15');

    const note = faker.lorem.sentence();
    cy.get("#case_contact_notes").type(note);
    cy.contains("Submit").click();

    cy.get(".modal-header").contains("Confirm Note Content"); // 'Double check your notes' dialog
    cy.contains("Continue Submitting").click();
    cy.contains("Case contact was successfully created.").should("exist");
    cy.contains(note).should("exist")
  });
});
