const emancipationPage = {
  saveOperationSuccessful: false,
  savePath: window.location.pathname + '/save',
  waitingSaveOperationCount: 0
}

// Shows an error notification
//  @param    {string | Error}  error The error to be displayed
//  @throws   {TypeError}  for a parameter of the incorrect type
function notifyError(error) {
  if (error instanceof Error) {
    error = error.message
  }

  if (typeof error !== 'string') {
    throw new TypeError('Param error is neither a string or Error object')
  }

  emancipationPage.notifications.append(`
  <div class="async-failure-indicator">
    Error: ${error}
    <button class="btn btn-danger btn-sm">×</button>
  </div>`).find('.async-failure-indicator button').click( function () {
    $(this).parent().remove()
  })
}

// Called when an async operation completes. May show notifications describing how the operation completed
//  @param    {string | Error=}  error The error to be displayed if there was an error
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {Error}      for trying to resolve more async operations than the amount currently awaiting
function resolveAsyncOperation (error) {
  if (emancipationPage.waitingSaveOperationCount < 1) {
    throw new Error('Attempted to resolve an async operation when awaiting none')
  }

  if (error instanceof Error) {
    error = error.message
  }

  if (error) {
    if (typeof error !== 'string') {
      throw new TypeError('Param error is not a string')
    }

    emancipationPage.notifications.append(`
    <div class="async-failure-indicator">
      Error: ${error}
      <button class="btn btn-danger btn-sm">×</button>
    </div>`).find('.async-failure-indicator button').click( function () {
      $(this).parent().remove()
    })
  } else {
    emancipationPage.saveOperationSuccessful = true
  }

  emancipationPage.waitingSaveOperationCount--

  if (emancipationPage.waitingSaveOperationCount === 0) {
    emancipationPage.asyncWaitIndicator.hide()

    if (emancipationPage.saveOperationSuccessful) {
      emancipationPage.asyncSuccessIndicator.show()

      setTimeout(function () {
        emancipationPage.asyncSuccessIndicator.hide()
      }, 2000)
    }

    emancipationPage.saveOperationSuccessful = false
  }
}

// Shows the saving notification
function waitForAsyncOperation () {
  emancipationPage.waitingSaveOperationCount++
  emancipationPage.asyncWaitIndicator.show()
}

// Adds or deletes an option from the current casa case
//  @param    {string}            optionAction
//    'add'     to add an option to the case
//    'delete'  to remove an option from the case
//    'set'     to set the option for a mutually exclusive category
//  @param    {integer | string}  optionId The id of the emancipation option to add or delete
//  @returns  {array} a jQuery jqXHR object. See https://api.jquery.com/jQuery.ajax/#jqXHR
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if optionId is negative
function changeOptions(optionAction, optionId){
  // Input check
  if (typeof optionId === 'string') {
    let optionIdAsNum = parseInt(optionId)

    if (!optionIdAsNum) {
      throw new TypeError('Param optionId is not an integer')
    } else if (optionIdAsNum < 0) {
      throw new RangeError('Param optionId cannot be negative')
    }
  } else {
    if(!Number.isInteger(optionId)) {
      throw new TypeError('Param optionId is not an integer')
    } else if (optionId < 0) {
      throw new RangeError('Param optionId cannot be negative')
    }
  }

  waitForAsyncOperation()

  // Post request
  return $.post(emancipationPage.savePath, {
    option_action: optionAction,
    option_id: optionId
  }).done(function (response, textStatus) {
    if (response.error) {
      resolveAsyncOperation(response.error)
    } else if (response === 'success'){
      resolveAsyncOperation()
    } else {
      resolveAsyncOperation('Unknown response')
    }
  }).fail(function (jqXHR, textStatus, error) {
    resolveAsyncOperation(error)
  })
}

$('document').ready(() => {
  emancipationPage.emancipationSelects = $('.emancipation-select')
  emancipationPage.notifications = $('#async-notifications')
  emancipationPage.asyncSuccessIndicator = emancipationPage.notifications.find('#async-success-indicator')
  emancipationPage.asyncWaitIndicator = emancipationPage.notifications.find('#async-waiting-indicator')

  emancipationPage.emancipationSelects.each(function() {
    let thisSelect = $(this)

    thisSelect.data('prev', thisSelect.val())
  })

  emancipationPage.emancipationSelects.change(function(data) {
    let thisSelect = $(this)

    if (thisSelect.val()) {
      changeOptions('set', thisSelect.val())
    } else {
      changeOptions('delete', thisSelect.data().prev)
    }

    thisSelect.data('prev', thisSelect.val());
  })

  $('.emancipation-check-box').change(function() {
    let thisCheckBox = $(this)

    if (thisCheckBox.prop('checked')) {
      changeOptions('add', thisCheckBox.val())
    } else {
      changeOptions('delete', thisCheckBox.val())
    }
  })
})
