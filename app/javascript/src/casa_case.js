/* eslint-env jquery */

import Swal from 'sweetalert2'

function addCourtMandateInput () {
  const list = '#mandates-list-container'
  const index = $(`${list} textarea`).length
  const html = courtMandateHtml(index)

  $(list).append(html.entry)
  const lastEntry = $(list).children(':last')

  $(lastEntry).append(html.textarea)
  $(lastEntry).append(html.select)
  $(lastEntry).children(':first').trigger('focus')
}

function removeMandateWithConfirmation () {
  const text = 'Are you sure you want to remove this court mandate? Doing so will ' +
               'delete all records of it unless it was included in a previous court report.'
  Swal.fire({
    icon: 'warning',
    title: 'Delete court mandate?',
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
        text: 'Court mandate has been removed.',
        showCloseButton: true
      })
    },
    error: () => {
      Swal.fire({
        icon: 'error',
        text: 'Something went wrong when attempting to delete this court mandate.',
        showCloseButton: true
      })
    }
  })
}

function courtMandateHtml (index) {
  const selectOptions = '<option value="">Set Implementation Status</option>' +
                        '<option value="not_implemented">Not implemented</option>' +
                        '<option value="partially_implemented">Partially implemented</option>' +
                        '<option value="implemented">Implemented</option>'
  return {
    entry: '<div class="court-mandate-entry"></div>',

    textarea: `<textarea name="casa_case[case_court_mandates_attributes][${index}][mandate_text]"\
                 id="casa_case_case_court_mandates_attributes_${index}_mandate_text"></textarea>`,

    select: `<select class="implementation-status"\
                 name="casa_case[case_court_mandates_attributes][${index}][implementation_status]"\
                 id="casa_case_case_court_mandates_attributes_${index}_implementation_status">\
                 ${selectOptions}\
               </select>`
  }
}

$('document').ready(() => {
  $('button#add-mandate-button').on('click', addCourtMandateInput)
  $('button.remove-mandate-button').on('click', removeMandateWithConfirmation)
})
