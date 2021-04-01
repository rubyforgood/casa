function add_court_mandate_input () {
  const list = '#mandates-list-container'
  const index = $(`${list} textarea`).length

  const entry_class = 'court-mandate-entry'
  const entry_html = `<div class="${entry_class}"></div>`

  const textarea_html = `<textarea name="casa_case[case_court_mandates_attributes][${index}][mandate_text]"\
id="casa_case_case_court_mandates_attributes_${index}_mandate_text">\
</textarea>`

  const select_options = `<option value="">Set Implementation Status</option>\
<option value="not_implemented">Not implemented</option>\
<option value="partially_implemented">Partially implemented</option>\
<option value="implemented">Implemented</option>`

  const select_html = `<select class="select-implementation-status"\
name="casa_case[case_court_mandates_attributes][${index}][implementation_status]"\
id="casa_case_case_court_mandates_attributes_${index}_implementation_status">\
${select_options}\
</select>`

  $(list).append(entry_html)
  let last_entry = $(list).children(':last')

  $(last_entry).append(textarea_html)
  $(last_entry).append(select_html)
  $(last_entry).children(':first').trigger('focus')
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
