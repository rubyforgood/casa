import NestedForm from 'stimulus-rails-nested-form'
import Swal from 'sweetalert2'

export default class extends NestedForm {
  //
  static targets = ["selectedStandard"]

  remove (e) {
    const wrapper = e.target.closest(this.wrapperSelectorValue)
    if (wrapper.dataset.newRecord !== 'true' && wrapper.dataset.type === 'COURT_ORDER') {
      this.removeCourtOrderWithConfirmation(e, wrapper)
    } else {
      super.remove(e)
    }
  }

  addStandardCourtOrder (e) {
    const dropdownValue = $(this.selectedStandardTarget).val()
    
    // TODO: actually undo this, have "Custom court order" be a value in the drop down, which will add a blank court order
    if (dropdownValue !== "") {
      super.add(e)
      const $textarea = $('#court-orders-list-container .court-order-entry:last textarea.court-order-text-entry')
      $textarea.val(dropdownValue)
    }
  }

  removeCourtOrderWithConfirmation (e, wrapper) {
    const text = 'Are you sure you want to remove this court order? Doing so will ' +
      'delete all records of it unless it was included in a previous court report.'
    Swal.fire({
      icon: 'warning',
      title: 'Delete court order?',
      text,
      showCloseButton: true,
      showCancelButton: true,
      focusConfirm: false,

      confirmButtonColor: '#d33',
      cancelButtonColor: '#39c',

      confirmButtonText: 'Delete',
      cancelButtonText: 'Go back'
    }).then((result) => {
      if (result.isConfirmed) {
        this.removeCourtOrder(e, wrapper)
      }
    })
  }

  removeCourtOrder (e, wrapper) {
    super.remove(e)
    wrapper.classList.remove('d-flex')
  }
}
