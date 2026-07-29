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

    if (selectedValue !== '') {
      const $textarea = $('#court-orders-list-container .court-order-entry:last textarea.court-order-text-entry')
      $textarea.val(selectedValue)
    }
  }
}
