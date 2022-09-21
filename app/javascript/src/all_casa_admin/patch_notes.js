const AsyncNotifier = require('../async_notifier')
const TypeChecker = require('../type_checker')
const patchNotePath = window.location.pathname
const patchNoteFormBeforeEditData = {}
const patchNoteFunctions = {} // A hack to be able to alphabetize functions

let pageNotifier

jQuery.ajaxSetup({
  beforeSend: function () {
    pageNotifier.startAsyncOperation()
  }
})

// Inserts a patch note display after the create patch note form in the patch note list and styles it as new
//  @param    {number} patchNoteGroupId  The id of the group allowed to view the patch note
//  @param    {jQuery} patchNoteList     A jQuery object representing the patch note list
//  @param    {string} patchNoteText     The text of the patch note
//  @param    {number} patchNoteTypeId   The id of the patch note type
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if an id parameter is negative
patchNoteFunctions.addPatchNoteUI = function (patchNoteGroupId, patchNoteId, patchNoteList, patchNoteText, patchNoteTypeId) {
  TypeChecker.checkPositiveInteger(patchNoteGroupId, 'patchNoteGroupId')
  TypeChecker.checkPositiveInteger(patchNoteId, 'patchNoteId')
  TypeChecker.checkPositiveInteger(patchNoteTypeId, 'patchNoteTypeId')
  TypeChecker.checkNonEmptyJQueryObject(patchNoteList, 'patchNoteList')
  TypeChecker.checkString(patchNoteText, 'patchNoteText')

  const newPatchNoteForm = patchNoteList.children().eq(1)

  if (!(newPatchNoteForm.length)) {
    throw new ReferenceError('Could not find new patch note form')
  }

  const newPatchNoteUI = newPatchNoteForm.clone()
  const newPatchNoteUIFormInputs = patchNoteFunctions.getPatchNoteFormInputs(newPatchNoteUI.children())

  newPatchNoteUI.addClass('new')
  newPatchNoteUI.children().attr('id', `patch-note-${patchNoteId}`)
  newPatchNoteUIFormInputs.noteTextArea.val(patchNoteText)
  newPatchNoteUIFormInputs.dropdownGroup.children().removeAttr('selected')
  newPatchNoteUIFormInputs.dropdownGroup.children(`option[value="${patchNoteGroupId}"]`).attr('selected', true)
  newPatchNoteUIFormInputs.dropdownType.children().removeAttr('selected')
  newPatchNoteUIFormInputs.dropdownType.children(`option[value="${patchNoteTypeId}"]`).attr('selected', true)
  newPatchNoteUIFormInputs.buttonControls.parent().html(`
    <button type="button" class="btn btn-primary button-edit">
      <i class="fa-solid fa-pen-to-square"></i>Edit
    </button>
    <button type="button" class="btn btn-danger button-delete">
      <i class="fa-solid fa-trash-can"></i>Delete
    </button>
  `)

  newPatchNoteForm.after(newPatchNoteUI)
  patchNoteFunctions.initPatchNoteForm(newPatchNoteUI)
}

// Creates a patch note
//  @param    {number} patchNoteGroupId  The id of the group allowed to view the patch note
//  @param    {string} patchNoteText     The text of the patch note
//  @param    {number} patchNoteTypeId   The id of the patch note type
//  @returns  {array} a jQuery jqXHR object. See https://api.jquery.com/jQuery.ajax/#jqXHR
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if an id parameter is negative
patchNoteFunctions.createPatchNote = function (patchNoteGroupId, patchNoteText, patchNoteTypeId) {
  // Input check
  TypeChecker.checkPositiveInteger(patchNoteGroupId, 'patchNoteGroupId')
  TypeChecker.checkPositiveInteger(patchNoteTypeId, 'patchNoteTypeId')
  TypeChecker.checkString(patchNoteText, 'patchNoteText')

  // Post request
  return $.post(patchNotePath, {
    note: patchNoteText,
    patch_note_group_id: patchNoteGroupId,
    patch_note_type_id: patchNoteTypeId
  })
    .then(function (response, textStatus, jqXHR) {
      if (response.errors) {
        return $.Deferred().reject(jqXHR, textStatus, response.error)
      } else if (response.status && response.status === 'created') {
        patchNoteFunctions.resolveAsyncOperation()
      } else {
        patchNoteFunctions.resolveAsyncOperation('Unknown response')
      }

      return response
    })
    .fail(function (jqXHR, textStatus, error) {
      patchNoteFunctions.resolveAsyncOperation(error)
    })
}

// Deletes a patch note
//  @param    {number} .parent().parent()patchNoteId The id of the patch note deleted
//  @returns  {array} a jQuery jqXHR object. See https://api.jquery.com/jQuery.ajax/#jqXHR
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if optionId is negative
patchNoteFunctions.deletePatchNote = function (patchNoteId) {
  TypeChecker.checkPositiveInteger(patchNoteId, 'patchNoteId')

  // Post request
  return $.ajax({
    url: `${patchNotePath}/${patchNoteId}`,
    type: 'DELETE'
  })
    .then(function (response, textStatus, jqXHR) {
      if (response.errors) {
        return $.Deferred().reject(jqXHR, textStatus, response.error)
      } else if (response.status && response.status === 'ok') {
        patchNoteFunctions.resolveAsyncOperation()
      } else {
        patchNoteFunctions.resolveAsyncOperation('Unknown response')
      }

      return response
    })
    .fail(function (jqXHR, textStatus, error) {
      patchNoteFunctions.resolveAsyncOperation(error)
    })
}

// Disables all form elements of a patch note form
//  @param    {object} patchNoteFormElements An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormElements()
//  @throws   {TypeError} for a parameter of the incorrect type
patchNoteFunctions.disablePatchNoteForm = function (patchNoteFormElements) {
  for (const formElement of Object.values(patchNoteFormElements)) {
    formElement.prop('disabled', true)
  }
}

// Enables all form elements of a patch note form
//  @param    {object} patchNoteFormElements An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormElements()
//  @throws   {TypeError} for a parameter of the incorrect type
patchNoteFunctions.enablePatchNoteForm = function (patchNoteFormElements) {
  for (const formElement of Object.values(patchNoteFormElements)) {
    formElement.removeAttr('disabled')
  }
}

// Get all form elements of a patch note in edit mode
//  @param    {jQuery} patchNoteElement The direct parent of the form elements
//  @returns  {object} An object containing jQuery objects in this form
//    {
//      dropdownGroup:  The select for the patch note's user visibility group
//      dropdownType:   The select for the patch note's type
//      noteTextArea:   The textarea containing the patch note
//      buttonControls: A list of all the buttons at the bottom of the form
//    }
//  @throws   {TypeError}      for a parameter of the incorrect type
//  @throws   {ReferenceError} if an element could not be found
patchNoteFunctions.getPatchNoteFormInputs = function (patchNoteElement) {
  TypeChecker.checkNonEmptyJQueryObject(patchNoteElement, 'patchNoteElement')

  const selects = patchNoteElement.children('.label-and-select').children('select')

  const fields = {
    dropdownGroup: selects.eq(1),
    dropdownType: selects.eq(0),
    noteTextArea: patchNoteElement.children('textarea'),
    buttonControls: patchNoteElement.children('.patch-note-button-controls').children('button')
  }

  for (const fieldName of Object.keys(fields)) {
    const field = fields[fieldName]

    if (!((field instanceof jQuery) && field.length)) {
      throw new ReferenceError(`Could not find form element ${fieldName}`)
    }
  }

  return fields
}

// Get the id of a patch note from its form
//  @param   {object} patchNoteForm A jQuery object representing the div with the patch note's id
//  @returns {number} The id of the patch note as a number
//  @throws  {TypeError}  for a parameter of the incorrect type
patchNoteFunctions.getPatchNoteId = function (patchNoteForm) {
  TypeChecker.checkNonEmptyJQueryObject(patchNoteForm)

  return Number.parseInt(patchNoteForm.attr('id').match(/patch-note-(\d+)/)[1])
}

// Add event listeners to a patch note form
//  @param {object} patchNoteForm A jQuery object representing the patch note form
//  @throws   {TypeError}  for a parameter of the incorrect type
patchNoteFunctions.initPatchNoteForm = function (patchNoteForm) {
  TypeChecker.checkNonEmptyJQueryObject(patchNoteForm)

  patchNoteForm.find('.button-delete').click(patchNoteFunctions.onDeletePatchNote)
  patchNoteForm.find('.button-edit').click(patchNoteFunctions.onEditPatchNote)
}

// Called when the delete button is pressed on a patch note form
patchNoteFunctions.onDeletePatchNote = function () {
  const patchNoteFormContainer = $(this).parent().parent()
  const formInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteFormContainer)

  patchNoteFunctions.disablePatchNoteForm(formInputs)

  patchNoteFunctions.deletePatchNote(
    patchNoteFunctions.getPatchNoteId(patchNoteFormContainer)
  ).then(function () {
    patchNoteFormContainer.parent().remove()
  }).fail(function () {
    patchNoteFunctions.enablePatchNoteForm(formInputs)
  })
}

// Called when the delete button is pressed on a patch note form
patchNoteFunctions.onEditPatchNote = function () {
  const patchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs($(this).parent().parent())

  patchNoteFunctions.enablePatchNoteFormEditMode(patchNoteFormInputs)
}

// Called when an async operation completes. May show notifications describing how the operation completed
//  @param    {string | Error=}  error The error to be displayed(optional)
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {Error}      for trying to resolve more async operations than the amount currently awaiting
patchNoteFunctions.resolveAsyncOperation = function (error) {
  if (error instanceof Error) {
    error = error.message
  }

  pageNotifier.stopAsyncOperation(error)
}

// Change a patch note form into edit mode
//  @param  {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormElements()
//  @throws {TypeError} for a parameter of the incorrect type
patchNoteFunctions.enablePatchNoteFormEditMode = function (patchNoteFormInputs) {
  try {
    patchNoteFormBeforeEditData[patchNoteFunctions.getPatchNoteId(patchNoteFormInputs.noteTextArea.parent())] = {
      note: patchNoteFormInputs.noteTextArea.val(),
      groupId: Number.parseInt(patchNoteFormInputs.dropdownGroup.val()),
      typeId: Number.parseInt(patchNoteFormInputs.dropdownType.val())
    }

    console.log(patchNoteFormBeforeEditData)
  } catch (e) {
    pageNotifier.notify('Failed to save patch note form data before editing', 'error')
    throw e
  }

  patchNoteFunctions.enablePatchNoteForm(patchNoteFormInputs)

  // Change button controls
  //   Clear click listeners
  patchNoteFormInputs.buttonControls.off()

  const buttonLeft = patchNoteFormInputs.buttonControls.siblings('.button-edit')
  const buttonRight = patchNoteFormInputs.buttonControls.siblings('.button-delete')

  buttonLeft.html('<i class="fas fa-save"></i> Save')
  buttonLeft.removeClass('button-edit')
  buttonLeft.addClass('button-save')

  buttonRight.html('<i class="fa-solid fa-xmark"></i> Cancel')
  buttonRight.removeClass('button-delete')
  buttonRight.removeClass('btn-danger')
  buttonRight.addClass('button-cancel')
  buttonRight.addClass('btn-secondary')
}

$('document').ready(() => {
  if (!(window.location.pathname.includes('patch_notes'))) {
    return
  }

  try {
    const asyncNotificationsElement = $('#async-notifications')
    pageNotifier = new AsyncNotifier(asyncNotificationsElement)

    const patchNoteList = $('#patch-note-list')
    const newPatchNoteFormElements = patchNoteFunctions.getPatchNoteFormInputs($('#new-patch-note'))

    newPatchNoteFormElements.buttonControls.click(() => {
      if (!(newPatchNoteFormElements.noteTextArea.val())) {
        pageNotifier.notify('Cannot save an empty patch note', 'warn')
        return
      }

      patchNoteFunctions.disablePatchNoteForm(newPatchNoteFormElements)

      const patchNoteGroupId = Number.parseInt(newPatchNoteFormElements.dropdownGroup.val())
      const patchNoteTypeId = Number.parseInt(newPatchNoteFormElements.dropdownType.val())
      const patchNoteText = newPatchNoteFormElements.noteTextArea.val()

      patchNoteFunctions.createPatchNote(
        patchNoteGroupId,
        patchNoteText,
        patchNoteTypeId
      ).then(function (response) {
        newPatchNoteFormElements.noteTextArea.val('')
        patchNoteFunctions.addPatchNoteUI(patchNoteGroupId, response.id, patchNoteList, patchNoteText, patchNoteTypeId)
      }).fail(function (err) {
        pageNotifier.notify('Failed to update UI', 'error')
        pageNotifier.notify(err.message, 'error')
        console.error(err)
      }).always(function () {
        patchNoteFunctions.enablePatchNoteForm(newPatchNoteFormElements)
      })
    })

    $('#patch-note-list .button-delete').click(patchNoteFunctions.onDeletePatchNote)
    $('#patch-note-list .button-edit').click(patchNoteFunctions.onEditPatchNote)
  } catch (err) {
    pageNotifier.notify('Could not intialize app', 'error')
    pageNotifier.notify(err.message, 'error')
    console.error(err)
  }
})
