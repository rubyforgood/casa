class AddFields {
  constructor() {
    this.links = document.querySelectorAll('.add_fields')
    this.iterateLinks()
  }

  iterateLinks() {
    if (this.links.length === 0) return
    this.links.forEach(link => {
      link.addEventListener('click', e => {
        this.handleClick(link, e)
      })
    })
  }

  handleClick(link, e) {
    if (!link || !e) return
    e.preventDefault()
    link.insertAdjacentHTML('beforebegin', 
    `<input placeholder="Enter amount" 
      class="form-control other-expense-amount" 
      min="0" 
      max="1000"
      step="0.01"
      type="number"
      name="case_contact[additional_expenses][][${1}][other_expense_amount]" 
      id="case_contact_additional_expense_0_other_expense_amount">
      <input placeholder="Describe the expense" 
      class="form-control other-expenses-describe" 
      type="text"  
      name="case_contact[additional_expenses][][${1}][other_expenses_describe]" 
      id="case_contact_additional_expense_0_other_expenses_describe">`)
  }
}

window.addEventListener('load', () => new AddFields())
