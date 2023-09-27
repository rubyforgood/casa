const AsyncNotifier = require('../notifier')
const TypeChecker = require('../type_checker')
const patchNotePath = window.location.pathname
const patchNoteFormBeforeEditData = {}
const patchNoteFunctions = {} // A hack to be able to alphabetize functions

let pageNotifier

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
    <button type="button" class="main-btn primary-btn btn-hovert button-edit">
      <i class="lni lni-pencil-alt mr-10"></i>Edit
    </button>
    <button type="button" class="main-btn danger-btn btn-hover button-delete">
      <i class="lni lni-trash-can mr-10"></i>Delete
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
  // return $.post(patchNotePath, {
  //   note: patchNoteText,
  //   patch_note_group_id: patchNoteGroupId,
  //   patch_note_type_id: patchNoteTypeId
  // })
  return $.ajax({
    url: patchNotePath,
    type: 'POST',
    data: {
      note: patchNoteText,
      patch_note_group_id: patchNoteGroupId,
      patch_note_type_id: patchNoteTypeId
    },
    beforeSend: function () {
      pageNotifier.startAsyncOperation()
    }
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

  return $.ajax({
    url: `${patchNotePath}/${patchNoteId}`,
    type: 'DELETE',
    beforeSend: function () {
      pageNotifier.startAsyncOperation()
    }
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
//  @param    {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormInputs()
//  @throws   {TypeError} for a parameter of the incorrect type
patchNoteFunctions.disablePatchNoteForm = function (patchNoteFormInputs) {
  for (const formInput of Object.values(patchNoteFormInputs)) {
    formInput.prop('disabled', true)
  }
}

// Enables all form elements of a patch note form
//  @param    {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormInputs()
//  @throws   {TypeError} for a parameter of the incorrect type
patchNoteFunctions.enablePatchNoteForm = function (patchNoteFormInputs) {
  for (const formInput of Object.values(patchNoteFormInputs)) {
    formInput.removeAttr('disabled')
  }
}

// Change a patch note form into edit mode
//  @param  {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormInputs()
//  @throws {TypeError} for a parameter of the incorrect type
patchNoteFunctions.enablePatchNoteFormEditMode = function (patchNoteFormInputs) {
  TypeChecker.checkObject(patchNoteFormInputs, 'patchNoteFormInputs')

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

  patchNoteFunctions.initPatchNoteForm(patchNoteFormInputs.noteTextArea.parent())
}

// Change a patch note form out of edit mode
//  @param  {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormInputs()
//  @throws {TypeError} for a parameter of the incorrect type
patchNoteFunctions.exitPatchNoteFormEditMode = function (patchNoteFormInputs) {
  TypeChecker.checkObject(patchNoteFormInputs, 'patchNoteFormInputs')

  patchNoteFormInputs.noteTextArea.prop('disabled', true)
  patchNoteFormInputs.dropdownGroup.prop('disabled', true)
  patchNoteFormInputs.dropdownType.prop('disabled', true)

  // Change button controls
  //   Clear click listeners
  patchNoteFormInputs.buttonControls.off()

  const buttonLeft = patchNoteFormInputs.buttonControls.siblings('.button-save')
  const buttonRight = patchNoteFormInputs.buttonControls.siblings('.button-cancel')

  buttonLeft.html('<i class="fa-solid fa-pen-to-square"></i> Edit')
  buttonLeft.removeClass('button-save')
  buttonLeft.addClass('button-edit')

  buttonRight.html('<i class="fa-solid fa-trash-can"></i> Delete')
  buttonRight.removeClass('btn-secondary')
  buttonRight.removeClass('button-cancel')
  buttonRight.addClass('btn-danger')
  buttonRight.addClass('button-delete')

  patchNoteFunctions.initPatchNoteForm(patchNoteFormInputs.noteTextArea.parent())
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
  TypeChecker.checkNonEmptyJQueryObject(patchNoteForm, 'patchNoteForm')

  return Number.parseInt(patchNoteForm.attr('id').match(/patch-note-(\d+)/)[1])
}

// Add event listeners to a patch note form
//  @param {object} patchNoteForm A jQuery object representing the patch note form
//  @throws   {TypeError}  for a parameter of the incorrect type
patchNoteFunctions.initPatchNoteForm = function (patchNoteForm) {
  TypeChecker.checkNonEmptyJQueryObject(patchNoteForm, 'patchNoteForm')

  patchNoteForm.find('.button-cancel').click(patchNoteFunctions.onCancelEdit)
  patchNoteForm.find('.button-delete').click(patchNoteFunctions.onDeletePatchNote)
  patchNoteForm.find('.button-edit').click(patchNoteFunctions.onEditPatchNote)
  patchNoteForm.find('.button-save').click(patchNoteFunctions.onSavePatchNote)
}

// Called when the cancel button is pressed on a patch note form
patchNoteFunctions.onCancelEdit = function () {
  const patchNoteFormContainer = $(this).parent().parent()
  const formInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteFormContainer)

  patchNoteFunctions.patchNoteFormDataResetBeforeEdit(formInputs)
  patchNoteFunctions.exitPatchNoteFormEditMode(formInputs)
}

// Called when the create button is pressed on the new patch note form
patchNoteFunctions.onCreate = function () {
  try {
    const patchNoteList = $('#patch-note-list')
    const newPatchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs($('#new-patch-note'))

    if (!(newPatchNoteFormInputs.noteTextArea.val())) {
      pageNotifier.notify('Cannot save an empty patch note', 'warn')
      return
    }

    patchNoteFunctions.disablePatchNoteForm(newPatchNoteFormInputs)

    const patchNoteGroupId = Number.parseInt(newPatchNoteFormInputs.dropdownGroup.val())
    const patchNoteTypeId = Number.parseInt(newPatchNoteFormInputs.dropdownType.val())
    const patchNoteText = newPatchNoteFormInputs.noteTextArea.val()

    patchNoteFunctions.createPatchNote(
      patchNoteGroupId,
      patchNoteText,
      patchNoteTypeId
    ).then(function (response) {
      newPatchNoteFormInputs.noteTextArea.val('')
      patchNoteFunctions.addPatchNoteUI(patchNoteGroupId, response.id, patchNoteList, patchNoteText, patchNoteTypeId)
    }).fail(function (err) {
      pageNotifier.notify('Failed to update UI', 'error')
      pageNotifier.notify(err.message, 'error')
      console.error(err)
    }).always(function () {
      patchNoteFunctions.enablePatchNoteForm(newPatchNoteFormInputs)
    })
  } catch (err) {
    pageNotifier.notify('Failed to save patch note', 'error')
    pageNotifier.notify(err.message, 'error')
    console.error(err)
  }
}

// Called when the delete button is pressed on a patch note form
patchNoteFunctions.onDeletePatchNote = function () {
  const deleteButton = $(this)
  const patchNoteFormContainer = deleteButton.parent().parent()
  const formInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteFormContainer)

  switch (deleteButton.text().trim()) {
    case 'Delete':
      pageNotifier.notify('Click 2 more times to delete', 'warn')
      deleteButton.text('2')
      break
    case '2':
      deleteButton.text('1')
      break
    case '1':
      patchNoteFunctions.disablePatchNoteForm(formInputs)

      patchNoteFunctions.deletePatchNote(
        patchNoteFunctions.getPatchNoteId(patchNoteFormContainer)
      ).then(function () {
        patchNoteFormContainer.parent().remove()
      }).fail(function () {
        patchNoteFunctions.enablePatchNoteForm(formInputs)
        deleteButton.html('<i class="fa-solid fa-trash-can"></i> Delete')
      })

      break
  }
}

// Called when the delete button is pressed on a patch note form
patchNoteFunctions.onEditPatchNote = function () {
  const patchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs($(this).parent().parent())

  patchNoteFunctions.patchNoteFormDataSaveTemp(patchNoteFormInputs)
  patchNoteFunctions.enablePatchNoteFormEditMode(patchNoteFormInputs)
}

// Called when the save button is pressed on a patch note form in edit mode
patchNoteFunctions.onSavePatchNote = function () {
  const patchNoteForm = $(this).parents('.card-body')
  const patchNoteFormInputs = patchNoteFunctions.getPatchNoteFormInputs(patchNoteForm)

  if ($(this).parent().siblings('textarea').val() === '') {
    pageNotifier.notify('Cannot save a blank patch note', 'warn')
    return
  }

  const patchNoteGroupId = Number.parseInt(patchNoteFormInputs.dropdownGroup.val())
  const patchNoteId = patchNoteFunctions.getPatchNoteId(patchNoteForm)
  const patchNoteTypeId = Number.parseInt(patchNoteFormInputs.dropdownType.val())
  const patchNoteText = patchNoteFormInputs.noteTextArea.val()

  patchNoteFunctions.disablePatchNoteForm(patchNoteFormInputs)

  patchNoteFunctions.savePatchNote(
    patchNoteGroupId,
    patchNoteId,
    patchNoteText,
    patchNoteTypeId
  ).then(function (response) {
    patchNoteFormInputs.noteTextArea.prop('disabled', true)
    patchNoteFormInputs.dropdownGroup.prop('disabled', true)
    patchNoteFormInputs.dropdownType.prop('disabled', true)

    // Change button controls
    //   Clear click listeners
    patchNoteFormInputs.buttonControls.off()

    const buttonLeft = patchNoteFormInputs.buttonControls.siblings('.button-save')
    const buttonRight = patchNoteFormInputs.buttonControls.siblings('.button-cancel')

    buttonLeft.html('<i class="fa-solid fa-pen-to-square"></i> Edit')
    buttonLeft.removeClass('button-save')
    buttonLeft.addClass('button-edit')

    buttonRight.html('<i class="fa-solid fa-trash-can"></i> Delete')
    buttonRight.removeClass('btn-secondary')
    buttonRight.removeClass('button-cancel')
    buttonRight.addClass('btn-danger')
    buttonRight.addClass('button-delete')

    patchNoteFunctions.initPatchNoteForm(patchNoteFormInputs.noteTextArea.parent())
  }).fail(function (err) {
    pageNotifier.notify('Failed to update patch note', 'error')
    pageNotifier.notify(err.message, 'error')
    console.error(err)

    patchNoteFunctions.enablePatchNoteForm(patchNoteFormInputs)
  }).always(function () {
    patchNoteFormInputs.buttonControls.prop('disabled', false)
  })
}

// Set the value of a patch note form's inputs to before the form was put in edit mode
//  @param  {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormInputs()
//  @throws {TypeError} for a parameter of the incorrect type
patchNoteFunctions.patchNoteFormDataResetBeforeEdit = function (patchNoteFormInputs) {
  TypeChecker.checkObject(patchNoteFormInputs, 'patchNoteFormInputs')

  let patchNoteDataBeforeEditing

  try {
    patchNoteDataBeforeEditing = patchNoteFormBeforeEditData[patchNoteFunctions.getPatchNoteId(patchNoteFormInputs.noteTextArea.parent())]

    patchNoteFormInputs.noteTextArea.val(patchNoteDataBeforeEditing.note)
    patchNoteFormInputs.dropdownGroup.val(patchNoteDataBeforeEditing.groupId)
    patchNoteFormInputs.dropdownType.val(patchNoteDataBeforeEditing.typeId)
  } catch (e) {
    pageNotifier.notify('Failed to load patch note data from before editing', 'error')
    throw e
  }
}

// Save the values of the patch note form inputs
//  @param  {object} patchNoteFormInputs An object containing the form elements as jQuery objects like the object returned from getPatchNoteFormInputs()
//  @throws {TypeError} for a parameter of the incorrect type
patchNoteFunctions.patchNoteFormDataSaveTemp = function (patchNoteFormInputs) {
  TypeChecker.checkObject(patchNoteFormInputs, 'patchNoteFormInputs')

  try {
    patchNoteFormBeforeEditData[patchNoteFunctions.getPatchNoteId(patchNoteFormInputs.noteTextArea.parent())] = {
      note: patchNoteFormInputs.noteTextArea.val(),
      groupId: Number.parseInt(patchNoteFormInputs.dropdownGroup.val()),
      typeId: Number.parseInt(patchNoteFormInputs.dropdownType.val())
    }
  } catch (e) {
    pageNotifier.notify('Failed to save patch note form data before editing', 'error')
    throw e
  }
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

// Saves an edited patch note
//  @param    {number} patchNoteGroupId  The id of the group allowed to view the patch note
//  @param    {number} patchNoteId  The id of the patch note
//  @param    {string} patchNoteText     The text of the patch note
//  @param    {number} patchNoteTypeId   The id of the patch note type
//  @returns  {array} a jQuery jqXHR object. See https://api.jquery.com/jQuery.ajax/#jqXHR
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if an id parameter is negative
patchNoteFunctions.savePatchNote = function (patchNoteGroupId, patchNoteId, patchNoteText, patchNoteTypeId) {
  // Input check
  TypeChecker.checkPositiveInteger(patchNoteGroupId, 'patchNoteGroupId')
  TypeChecker.checkPositiveInteger(patchNoteId, 'patchNoteGroupId')
  TypeChecker.checkPositiveInteger(patchNoteTypeId, 'patchNoteTypeId')
  TypeChecker.checkString(patchNoteText, 'patchNoteText')

  // Post request
  return $.ajax({
    url: `${patchNotePath}/${patchNoteId}`,
    type: 'PUT',
    data: {
      note: patchNoteText,
      patch_note_group_id: patchNoteGroupId,
      patch_note_type_id: patchNoteTypeId
    },
    beforeSend: function () {
      pageNotifier.startAsyncOperation()
    }
  })
    .then(function (response, textStatus, jqXHR) {
      if (response.errors) {
        return $.Deferred().reject(jqXHR, textStatus, response.error)
      } else if (response.status && response.status === 'ok') {
        patchNoteFunctions.resolveAsyncOperation()
      } else {
        patchNoteFunctions.resolveAsyncOperation('Unknown response')
        console.error('Unexpected repsonse')
        console.error(response)
      }

      return response
    })
    .fail(function (jqXHR, textStatus, error) {
      patchNoteFunctions.resolveAsyncOperation(error)
    })
}

$(() => { // JQuery's callback for the DOM loading
  if (!(window.location.pathname.includes('patch_notes'))) {
    return
  }

  try {
    const asyncNotificationsElement = $('#notifications')
    pageNotifier = new AsyncNotifier(asyncNotificationsElement)

    $('#new-patch-note button').on('click', patchNoteFunctions.onCreate)
    $('#patch-note-list .button-delete').on('click', patchNoteFunctions.onDeletePatchNote)
    $('#patch-note-list .button-edit').on('click', patchNoteFunctions.onEditPatchNote)
  } catch (err) {
    pageNotifier.notify('Could not intialize app', 'error')
    pageNotifier.notify(err.message, 'error')
    console.error(err)
  }
})
