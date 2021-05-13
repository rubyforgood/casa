context("Logging into cypress as a volunteer", () => {
  before(() => {
    cy.visit("0.0.0.0:4040");
    cy.loginAsVolunteer();
  });
  it("should go to the new case contact page", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.get('[href="/case_contacts"]').click();
    cy.get(".col-sm-12 > .btn").click();
    cy.contains("New Case Contact").should("exist");  //$.i18n(".new_contact")
  });
});
