module.exports = class CourtOrderList {
  // @param {object} courtOrdersWidget The div containing the list of court orders
  constructor (courtOrdersWidget) {
    this.courtOrdersWidget = courtOrdersWidget
  }

  // Adds a row containing a text field to write the court order and a dropdown to specify the order status
  addCourtOrder () {
    const index = this.courtOrdersWidget.find('.court-mandate-entry').length
    const courtOrderRow = $(`\
    <div class="court-mandate-entry">\
      <textarea
        name="casa_case[case_court_mandates_attributes][${index}][mandate_text]"\
        id="casa_case_case_court_mandates_attributes_${index}_mandate_text"></textarea>
      <select\
      class="implementation-status"\
      name="casa_case[case_court_mandates_attributes][${index}][implementation_status]"\
      id="casa_case_case_court_mandates_attributes_${index}_implementation_status">\
        <option value="">Set Implementation Status</option>
        <option value="not_implemented">Not implemented</option>
        <option value="partially_implemented">Partially implemented</option>
        <option value="implemented">Implemented</option>
      </select>
    </div>`)

    this.courtOrdersWidget.append(courtOrderRow)
    courtOrderRow.children('textarea').trigger('focus')
  }

  // Removes a row of elements representing a single court order
  // and removes the accompanying hidden input containing the order id
  //   @param {object} order              The jQuery object representing the court order div to remove
  //   @param {object} orderHiddenIdInput The jQuery object representing the hidden court order id input
  removeCourtOrder (order, orderHiddenIdInput) {
    // const index = order.index()
    order.remove()
    orderHiddenIdInput.remove()
  }
}
