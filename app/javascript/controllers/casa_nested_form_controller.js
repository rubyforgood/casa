// https://www.stimulus-components.com/docs/stimulus-rails-nested-form/
import NestedForm from '@stimulus-components/rails-nested-form'

// NOTE: Using the base nested-form for multiple nested attribute forms in case_contacts form
// did not work. This was added to fix that, and adds a simple confirmation dialog for removing items.
// It can be used in place of nested-form, and is also useful for debugging rails-nested-form.

// Connects to data-controller="casa-nested-form"
export default class extends NestedForm {
  connect () {
    super.connect()
  }

  add (e) {
    super.add(e)
  }

  remove (e) {
    super.remove(e)
  }

  windowConfirmRemove (e) {
    const text = 'Are you sure you want to remove this item?'
    if (window.confirm(text)) {
      this.remove(e)
    }
  }
}
