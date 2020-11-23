import Swal from 'sweetalert2'
import Rails from '@rails/ujs'

window.Swal = Swal

// Behavior after click to confirm button
const confirmed = (element, result) => {
  // If result `success`
  if (result.value) {
    // Removing attribute for unbinding JS event.
    element.removeAttribute('data-confirm-swal')
    // Following a destination link
    element.click()
  }
}

// Display the confirmation dialog
const showConfirmationDialog = (element) => {
  const message = element.getAttribute('data-confirm-swal')
  const text = element.getAttribute('data-text')
  const onSuccess = element.getAttribute('data-success')
  const onFail = element.getAttribute('data-fail')

  Swal.fire({
    title: message || 'Are you sure?',
    text: text || '',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: onSuccess || 'Ok',
    cancelButtonText: onFail || 'No'
  }).then(result => confirmed(element, result))
}

const allowAction = (element) => {
  if (element.getAttribute('data-confirm-swal') === null) {
    return true
  }

  showConfirmationDialog(element)
  return false
}

function handleConfirm (element) {
  if (!allowAction(this)) {
    Rails.stopEverything(element)
  }
}

Rails.delegate(document, 'a[data-confirm-swal]', 'click', handleConfirm)
