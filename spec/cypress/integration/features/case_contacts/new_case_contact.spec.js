context('new Case Contact Event behavior', () => {
  describe('can submit the form', () => {
    before(() => { 
      cy.app('load_seeds').then(() => {
        cy.volunteerSignin()
      })
    })
    it('submits the default settings', () => {
      cy.visit('http://localhost:5002/case_contacts/new')  
      cy.get('#casa_case_id').select('111')
      cy.get('#contact_type').select('Youth')
      cy.get('#duration_minutes').select('15 minutes')
      cy.contains('Submit').click()
      cy.contains('Casa case: 111').should('exist')
      cy.contains('Contact type: youth').should('exist')
      cy.contains('Duration minutes: 15').should('exist')
      cy.contains('Occurred at: 2020-04-09').should('exist')
    })
  })
  describe('chooses the other contact type', () => {
    before(() => { 
      cy.app('load_seeds').then(() => {
        cy.volunteerSignin()
      })
    })
    it('chooses other as the contact type', () => {
      cy.visit('http://localhost:5002/case_contacts/new')
      cy.get('#casa_case_id').select('111')
      cy.get('#contact_type').select('Youth')
      cy.get('#duration_minutes').select('15 minutes')
      cy.get('#contact_type').select('Other')
      cy.contains('Submit').click()
      cy.contains('Casa case: 111').should('exist')
      cy.contains('Contact type: other').should('exist')
      cy.contains('Other type text:').should('exist')
      cy.contains('Duration minutes: 15').should('exist')
      cy.contains('Occurred at: 2020-04-09').should('exist')
    })
  })
})