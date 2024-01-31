import { Controller } from '@hotwired/stimulus'
import Swal from 'sweetalert2'

// Connects to data-controller="alert"
export default class extends Controller {
  // Any of these can be overridden from the view that calls this controller
  static values = {
    ignore: { type: Boolean, default: false },
    message: { type: String, default: 'Are you sure?' },
    title: { type: String, default: 'Confirm your choice' },
    icon: { type: String, default: 'warning' },
    showCloseButton: { type: Boolean, default: false },
    showCancelButton: { type: Boolean, default: true },
    focusConfirm: { type: Boolean, default: false },
    confirmColor: { type: String, default: '#d50100' },
    cancelColor: { type: String, default: '#4a6cf7' },
    confirmText: { type: String, default: 'Ok' },
    cancelText: { type: String, default: 'Cancel' }
  }

  confirm (e) {
    if (this.ignoreValue) return

    e.preventDefault()

    const text = this.messageValue
    Swal.fire({
      icon: this.iconValue,
      title: this.titleValue,
      text,
      showCloseButton: this.showCloseButtonValue,
      showCancelButton: this.showCancelButtonValue,
      focusConfirm: this.focusConfirmValue,

      confirmButtonColor: this.confirmColorValue,
      cancelButtonColor: this.cancelColorValue,

      confirmButtonText: this.confirmTextValue,
      cancelButtonText: this.cancelTextValue
    }).then((result) => {
      if (result.isConfirmed) {
        window.location.href = e.target.href
      }
    })
  }
}
