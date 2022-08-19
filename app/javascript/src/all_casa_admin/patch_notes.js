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

  const newPatchNoteFormElements = getPatchNoteFormInputs('new-patch-note')

  const disableNewPatchNoteForm = () => {
    for (const formElement of Object.values(newPatchNoteFormElements)) {
      formElement.prop('disabled', true)
    }
  }

  newPatchNoteFormElements.submitButton.click(() => {
    if (!(newPatchNoteFormElements.noteTextArea.val())) {
      patchNotePage.notifier.notify('Cannot save an empty patch note', 'warn')
      return
    }

    console.log(`Patch Note: ${newPatchNoteFormElements.noteTextArea.val()}`)
    console.log(`Patch Note Group ID: ${newPatchNoteFormElements.dropdownGroup.val()}`)
    console.log(`Patch Note Type ID: ${newPatchNoteFormElements.dropdownType.val()}`)

    disableNewPatchNoteForm()
    patchNotePage.notifier.startAsyncOperation()
  })
})
