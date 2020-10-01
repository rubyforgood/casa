context('Logging into cypress as a volunteer', () => {
  before(() => {
    cy.visit('http://127.0.0.1:8080')
  })
  it('should log in', () => {
    cy.loginAsVolunteer()
    cy.log('got here')
  })

})