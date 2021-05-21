context("Logging into cypress as a volunteer", () => {
  before(() => {
    cy.visit("0.0.0.0:4040");
    cy.loginAsVolunteer();
  });
  it("should edit the profile", () => {
    cy.get("#toggle-sidebar-js").click();
    cy.contains("Edit Profile").click();
    cy.contains("Change Password").click();
    cy.contains("Password Confirmation").should("exist");
    cy.contains("Update Profile").click();
    cy.contains("Profile was successfully updated.").should("exist");
  });
});
