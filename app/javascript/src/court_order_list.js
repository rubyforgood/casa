// Replaces a number in a string with its value -1
//   @param  {string} str The string containing the number to replace
//   @param  {number} num The number to replace
//   @return {string} The new string with the number decremented
function replaceNumberWithDecrement (str, num) {
  const captureStringWithoutNumPattern = new RegExp(`(^.*)${num}(.*$)`)
  const stringWithoutNum = str.match(captureStringWithoutNumPattern)

  return stringWithoutNum[1] + (num - 1) + stringWithoutNum[2]
}

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
    // Index relative to the other court orders excluding hidden inputs
    const index = order.index() / 2

    order.remove()
    orderHiddenIdInput.remove()

    // Decrement indicies of all siblings after deleted element
    this.courtOrdersWidget.find(`.court-mandate-entry:nth-child(n+${2 * index})`).each(function (originalSiblingIndex) {
      const courtMandateSibling = $(this)
      const courtMandateSiblingSelect = courtMandateSibling.find('select')
      const courtMandateSiblingTextArea = courtMandateSibling.find('textarea')

      courtMandateSiblingSelect.attr('name', replaceNumberWithDecrement(courtMandateSiblingSelect.attr('name'), originalSiblingIndex + index + 1))
      courtMandateSiblingTextArea.attr('name', replaceNumberWithDecrement(courtMandateSiblingTextArea.attr('name'), originalSiblingIndex + index + 1))
    })

    this.courtOrdersWidget.find(`input[type="hidden"]:nth-child(n+${2 * (index + 1)})`).each(function (originalSiblingIndex) {
      const courtMandateSiblingId = $(this)

      courtMandateSiblingId.attr('id', replaceNumberWithDecrement(courtMandateSiblingId.attr('id'), originalSiblingIndex + index + 1))
    })
  }
}
