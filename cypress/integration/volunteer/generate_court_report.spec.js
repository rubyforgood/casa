const path = require("path");

context("Logging into cypress as a volunteer", () => {
  before(() => {
    cy.visit("0.0.0.0:4040");
    cy.loginAsVolunteer();
  });
  it("should generate a court report", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.contains("Generate Court Reports").click();
    // Pick the first option from the case selection dropdown
    cy.get('#case-selection')
      .find('option').then(elements => {
        const option = elements[1].getAttribute('value');
        cy.get('#case-selection').select(option);

        cy.contains("Generate Report").click();

        const downloadsFolder = Cypress.config("downloadsFolder");
        cy.readFile(path.join(downloadsFolder, `${option}.docx`)).should("exist");
      });
  });
});
