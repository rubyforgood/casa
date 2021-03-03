function add_court_mandate_input () {
  const list = '#mandates-list-container'
  const index = $(`${list} textarea`).length

  const textarea_html = `<textarea name="casa_case[case_court_mandates_attributes][${index}][mandate_text]"\
id="casa_case_case_court_mandates_attributes_1_mandate_text">\
</textarea>`

  $(list).append(textarea_html)
  $(list).children(':last').trigger('focus')
}

function remove_mandate_with_confirmation () {
  Swal.fire({
    icon: 'warning',
    title: 'Delete court mandate?',
    text: 'Are you sure you want to remove this court mandate? Doing so will \
delete all records of it unless it was included in a previous court report.',

    showCloseButton: true,
    showCancelButton: true,
    focusConfirm: false,

    confirmButtonColor: '#d33',
    cancelButtonColor: '#39c',

    confirmButtonText: 'Delete',
    cancelButtonText: 'Go back'
  }).then((result) => {
    if (result.isConfirmed) {
      remove_mandate_action($(this))
    }
  })
}

function remove_mandate_action (ctx) {
  id_element = ctx.parent().next('input[type="hidden"]')
  id = id_element.val()

  $.ajax({
    url: `/case_court_mandates/${id}`,
    method: 'delete',
    success: () => {
      ctx.parent().remove()
      id_element.remove() // Remove form element since this mandate has been deleted

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

$('document').ready(() => {
  $('button#add-mandate-button').on('click', add_court_mandate_input)
  $('button.remove-mandate-button').on('click', remove_mandate_with_confirmation)
})
