const Notifier = require('../async_notifier')
const patchNotePage = {
}

// Get all form elements of a patch note in edit mode
//  @param    {number} patchNoteId The id of the patch note form
//  @throws   {TypeError}      for a parameter of the incorrect type
//  @throws   {ReferenceError} if an element could not be
function getPatchNoteFormInputs (patchNoteId) {
  if (typeof patchNoteId !== 'string') {
    throw new TypeError('Param patchNoteId must be a string')
  }

  const patchNoteElement = $(`#${patchNoteId}`)

  if (patchNoteElement.length) {
    const selects = patchNoteElement.children('.label-and-select').children('select')

    const fields = {
      dropdownGroup: selects.eq(1),
      dropdownType: selects.eq(0),
      noteTextArea: patchNoteElement.children('textarea'),
      submitButton: patchNoteElement.children('button')
    }

    for (const fieldName of Object.keys(fields)) {
      if (!(fields[fieldName] instanceof jQuery)) {
        throw new ReferenceError(`Could not find form element ${fieldName}`)
      }
    }

    return fields
  } else {
    return null
  }
}

$('document').ready(() => {
  const asyncNotificationsElement = $('#async-notifications')
  patchNotePage.notifier = new Notifier(asyncNotificationsElement)

  const newPatchNoteElement = $('#new-patch-note')
  const newPatchNoteGroupDropdown = $('#new-patch-note-group')
  const newPatchNoteTypeDropdown = $('#new-patch-note-type')

  const disableNewPatchNoteForm = () => {
    for (const formElement of Object.values(getPatchNoteFormInputs('new-patch-note'))) {
      formElement.prop('disabled', true)
    }
  }

  newPatchNoteElement.children('button').click(() => {
    console.log(`Patch Note: ${newPatchNoteElement.children('textarea').val()}`)
    console.log(`Patch Note Group ID: ${newPatchNoteGroupDropdown.val()}`)
    console.log(`Patch Note Type ID: ${newPatchNoteTypeDropdown.val()}`)

    disableNewPatchNoteForm()
    patchNotePage.notifier.startAsyncOperation()
  })

  patchNotePage.notifier.notify('test', 'warn')
})
