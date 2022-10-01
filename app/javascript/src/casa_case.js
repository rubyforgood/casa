/* eslint-env jquery */
/* global FormData */
/* global DOMParser */
/* global spinner */
/* global $ */

import Swal from 'sweetalert2'

const CourtOrderList = require('./court_order_list.js')
let courtOrders

function removeMandateWithConfirmation () {
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
      removeMandateAction($(this).parent())
    }
  })
}

function removeMandateAction (order) {
  const orderHiddenIdInput = order.next('input[type="hidden"]')

  $.ajax({
    url: `/case_court_orders/${orderHiddenIdInput.val()}`,
    method: 'delete',
    success: () => {
      courtOrders.removeCourtOrder(order, orderHiddenIdInput)
      Swal.fire({
        icon: 'success',
        text: 'Court order has been removed.',
        showCloseButton: true
      })
    },
    error: () => {
      Swal.fire({
        icon: 'error',
        text: 'Something went wrong when attempting to delete this court order.',
        showCloseButton: true
      })
    }
  })
}

function copyOrdersFromCaseWithConfirmation () {
  const id = $(this).next().val()
  const caseNumber = $('select.siblings-casa-cases').find(':selected').text()
  const text = `Are you sure you want to copy all orders from case #${caseNumber}?`
  Swal.fire({
    icon: 'warning',
    title: `Copy all orders from case #${caseNumber}?`,
    text,
    showCloseButton: true,
    showCancelButton: true,
    focusConfirm: false,

    confirmButtonColor: '#d33',
    cancelButtonColor: '#39c',

    confirmButtonText: 'Copy',
    cancelButtonText: 'Cancel'
  }).then((result) => {
    if (result.isConfirmed) {
      copyOrdersFromCaseAction(id, caseNumber)
    }
  })
}

function copyOrdersFromCaseAction (id, caseNumber) {
  $.ajax({
    url: `/casa_cases/${id}/copy_court_orders`,
    method: 'patch',
    data: {
      case_number_cp: caseNumber
    },
    success: () => {
      Swal.fire({
        icon: 'success',
        text: 'Court orders have been copied.',
        showCloseButton: true,
        timer: 2000
      }).then(() => window.location.reload(true))
    },
    error: () => {
      Swal.fire({
        icon: 'error',
        text: 'Something went wrong when attempting to copy court orders.',
        showCloseButton: true
      })
    }
  })
}

function showBtn (el) {
  el.classList.remove('d-none')
}

function hideBtn (el) {
  el.classList.add('d-none')
}

function disableBtn (el) {
  el.disabled = true
  el.classList.add('disabled')
  el.setAttribute('aria-disabled', true)
}

function enableBtn (el) {
  el.disabled = false
  el.classList.remove('disabled')
  el.removeAttribute('aria-disabled')
}

function showAlert (html) {
  const alertEl = new DOMParser().parseFromString(html, 'text/html').body.firstElementChild
  document.querySelector('.header-flash').replaceWith(alertEl)
}

function handleGenerateReport (e) {
  e.preventDefault()

  const formData = Object.fromEntries(new FormData(e.currentTarget.form))

  if (formData.case_number.length === 0) return

  const generateBtn = e.currentTarget
  disableBtn(generateBtn)

  const url = e.currentTarget.form.action
  const options = {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(formData)
  }
  showBtn(spinner)
  window.fetch(url, options)
    .then(response => {
      return response.json()
    })
    .then(data => {
      if (data.status !== 'ok') {
        showAlert(data.error_messages)
        enableBtn(generateBtn)
        hideBtn(spinner)
        return
      }
      hideBtn(spinner)
      enableBtn(generateBtn)
      window.open(data.link, '_blank')
    })
    .catch((error) => {
      console.error('Debugging info, error:', error)
    })
}

$('document').ready(() => {
  const courtOrdersListContainer = $('#court-orders-list-container')

  $('button.copy-court-button').on('click', copyOrdersFromCaseWithConfirmation)

  if ($('button.copy-court-button').length) {
    disableBtn($('button.copy-court-button')[0])
  }

  $('select.siblings-casa-cases').on('change', () => {
    if ($('select.siblings-casa-cases').find(':selected').text()) {
      enableBtn($('button.copy-court-button')[0])
    } else {
      disableBtn($('button.copy-court-button')[0])
    }
  })

  if (courtOrdersListContainer.length) {
    courtOrders = new CourtOrderList(courtOrdersListContainer)

    $('button#add-mandate-button').on('click', () => {
      courtOrders.addCourtOrder()
    })

    $('button.remove-mandate-button').on('click', removeMandateWithConfirmation)

    $('.court-mandates textarea').each(function () {
      $(this).height($(this).prop('scrollHeight'))
    })
  }

  $('#btnGenerateReport').on('click', handleGenerateReport)

  if (/\/casa_cases\/.*\?.*success=true/.test(window.location.href)) {
    $('#thank_you').modal('show')
  }
})

export {
  showBtn,
  hideBtn,
  disableBtn,
  enableBtn
}
