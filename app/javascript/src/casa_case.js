/* eslint-env jquery */
/* global FormData */
/* global DOMParser */
/* global spinner */

import Swal from 'sweetalert2'
const CourtOrderList = require('./court_order_list.js')
let courtOrders

function removeMandateWithConfirmation () {
  const text = 'Are you sure you want to remove this court order? Doing so will ' +
               'delete all records of it unless it was included in a previous court report.'
  Swal.fire({
    icon: 'warning',
    title: 'Delete court order?',
    text: text,
    showCloseButton: true,
    showCancelButton: true,
    focusConfirm: false,

    confirmButtonColor: '#d33',
    cancelButtonColor: '#39c',

    confirmButtonText: 'Delete',
    cancelButtonText: 'Go back'
  }).then((result) => {
    if (result.isConfirmed) {
      removeMandateAction($(this))
    }
  })
}

function removeMandateAction (ctx) {
  const idElement = ctx.parent().next('input[type="hidden"]')
  const id = idElement.val()

  $.ajax({
    url: `/case_court_mandates/${id}`,
    method: 'delete',
    success: () => {
      ctx.parent().remove()
      idElement.remove() // Remove form element since this mandate has been deleted

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

function showBtn (el) { el.classList.remove('d-none') }
function hideBtn (el) { el.classList.add('d-none') }
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
  courtOrders = new CourtOrderList($('#court-orders-list-container'))
  $('button#add-mandate-button').on('click', () => {
    courtOrders.addCourtOrder()
  })
  $('button.remove-mandate-button').on('click', removeMandateWithConfirmation)

  $('#btnGenerateReport').on('click', handleGenerateReport)

  $('.court-mandates textarea').each(function () {
    $(this).height($(this).prop('scrollHeight'))
  })
})
