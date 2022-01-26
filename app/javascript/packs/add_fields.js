class AddFields {
  constructor () {
    this.links = document.querySelectorAll('.add_fields')
    const addLinkCount = 0
    this.iterateLinks(addLinkCount)
  }

  iterateLinks (addLinkCount) {
    if (this.links.length === 0) return
    this.links.forEach(link => {
      link.addEventListener('click', e => {
        addLinkCount = addLinkCount + 1
        this.handleClick(link, e, addLinkCount)
      })
    })
  }

  handleClick (link, e, addLinkCount) {
    if (!link || !e) return
    e.preventDefault()
    link.insertAdjacentHTML('beforebegin',
    `<input placeholder="Enter amount" 
    class="form-control other-expense-amount"
    min="0"
    max="1000"
    step="0.01"
    type="number"
    name="case_contact[additional_expense][${addLinkCount}][other_expense_amount]"
    id="case_contact_additional_expense_${addLinkCount}_other_expense_amount
    ">
    <input placeholder="Describe the expense"
    class="form-control other-expenses-describe"
    type="text"
    name="case_contact[additional_expense][${addLinkCount}][other_expenses_describe]"
    id="case_contact_additional_expense_${addLinkCount}_other_expenses_describe
    ">
    <input type="hidden" name="case_contact[additional_expense][${addLinkCount}][id]" id="case_contact_additional_expense_${addLinkCount}_id">`)
  }
}

window.addEventListener('load', () => new AddFields())
