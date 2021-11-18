  // TODO - fix flakey spec ref: https://github.com/rubyforgood/casa/issues/2550#issuecomment-943474980
const path = require("path");

context.skip("Logging into cypress as a volunteer", () => {
  before(() => {
    cy.visit("0.0.0.0:4040");
    cy.loginAsVolunteer();
  });
  it("should generate a court report", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.contains("Generate Court Reports").click();

    // Pick the first non-blank option from the case selection dropdown
    cy.get("#case-selection option")
      .eq(1)
      .then((element) => {
        const option = element.val();
        cy.get("#case-selection").select(option, { force: true });

        cy.contains("Generate Report").click();

        const downloadsFolder = Cypress.config("downloadsFolder");
        cy.readFile(path.join(downloadsFolder, `${option}.docx`)).should("exist");
      });
  });
});
