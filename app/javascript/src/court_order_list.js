const $ = require('jquery')

module.exports = class CourtOrderList {
  // @param {object} courtOrdersWidget The div containing the list of court orders
  constructor (courtOrdersWidget) {
    this.courtOrdersWidget = courtOrdersWidget
  }

  // Adds a row containing a text field to write the court order and a dropdown to specify the order status
  addCourtOrder () {
  }

  // Removes a row of elements representing a single court order
  removeCourtOrder () {
  }
}
