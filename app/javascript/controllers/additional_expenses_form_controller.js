import NestedForm from 'stimulus-rails-nested-form'

export default class extends NestedForm {
  static targets = ['additionalExpense', 'target']

  add (event) {
    super.add(event)
    this.reindexFields()
  }

  remove (event) {
    super.remove(event)
    this.reindexFields()
  }

  reindexFields () {
    // Reindex fields so that nested parameters come in with consecutive
    // indexes starting at 0
    const containers = this.element.querySelectorAll('.expense-container')
    containers.forEach((container, index) => {
      container.querySelectorAll('input, select, textarea').forEach(field => {
        const newName = field.name.replace(/\[additional_expenses_attributes\]\[\d+\]/, `[additional_expenses_attributes][${index}]`)
        field.name = newName
        field.id = newName.replace(/\[/g, '_').replace(/\]/g, '')
      })

      container.querySelectorAll('label').forEach(label => {
        const forAttr = label.getAttribute('for')
        if (forAttr) {
          const newForAttr = forAttr.replace(/additional_expenses_attributes_\d+/, `additional_expenses_attributes_${index}`)
          label.setAttribute('for', newForAttr)
        }
      })
    })
  }
}
