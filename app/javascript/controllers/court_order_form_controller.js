import NestedForm from '@stimulus-components/rails-nested-form'

// Court-orders nested sub-form. Extends the shared nested-form controller: `add`
// clones a court-order row (prefilled from the standard-order select), and `remove`
// on an existing (persisted) order asks for confirmation first through the
// design-system <dialog> (the `modal` controller centers it and handles the backdrop)
// rather than deleting outright. New, unsaved rows are removed without a prompt.
export default class extends NestedForm {
  static targets = ['selectedCourtOrder', 'confirmDialog']

  remove (e) {
    const wrapper = e.target.closest(this.wrapperSelectorValue)
    if (wrapper.dataset.newRecord !== 'true' && wrapper.dataset.type === 'COURT_ORDER') {
      e.preventDefault()
      this.pendingWrapper = wrapper
      this.confirmDialogTarget.showModal()
    } else {
      super.remove(e)
    }
  }

  confirmRemove () {
    const wrapper = this.pendingWrapper
    if (wrapper) {
      wrapper.style.display = 'none'
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (destroyInput) destroyInput.value = '1'
      this.pendingWrapper = null
    }
    this.confirmDialogTarget.close()
  }

  add (e) {
    super.add(e)
    const selectedValue = $(this.selectedCourtOrderTarget).val()
    // The last entry, not `:last-of-type`: the rows share a parent with the insertion target div, so
    // `div:last-of-type` is that target (which has no textarea) rather than the row just added.
    const entries = document.querySelectorAll('#court-orders-list-container .court-order-entry')
    const textarea = entries.length ? entries[entries.length - 1].querySelector('textarea.court-order-text-entry') : null

    if (selectedValue !== '' && textarea) textarea.value = selectedValue

    // Move focus into the row that was just added. The row appends to the end of the list, which puts
    // it directly above the Add control -- correct for an "add another" list -- but the button keeps
    // focus otherwise, so a keyboard user has to go looking for the field they just created.
    if (textarea) {
      textarea.focus()
      // Caret after any prefilled standard-order text rather than before it.
      textarea.setSelectionRange(textarea.value.length, textarea.value.length)
    }
  }
}
