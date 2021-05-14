const path = require("path");

context("Logging into cypress as a volunteer", () => {
  before(() => {
    cy.visit("0.0.0.0:4040");
    cy.loginAsVolunteer();
  });
  it("should generate a court report", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.contains("Generate Court Reports").click();
    cy.get("#case-selection").select("CINA-18-1003 - non-transition");
    cy.contains("Generate Report").click();

    const downloadsFolder = Cypress.config("downloadsFolder");
    cy.readFile(path.join(downloadsFolder, "CINA-18-1003.docx")).should("exist");
  });
});
