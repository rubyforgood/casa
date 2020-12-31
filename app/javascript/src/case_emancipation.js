const emancipationPage = {
  saveOperationSuccessful: false,
  savePath: window.location.pathname + '/save',
  waitingSaveOperationCount: 0
}

// Shows an error notification
//  @param    {string | Error}  error The error to be displayed
//  @throws   {TypeError}  for a parameter of the incorrect type
function notifyError (error) {
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
  </div>`).find('.async-failure-indicator button').click(function () {
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
    </div>`).find('.async-failure-indicator button').click(function () {
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
//    'add_option'     to add an option to the case
//    'delete_option'  to remove an option from the case
//    'set_option'     to set the option for a mutually exclusive category
//  @param    {integer | string}  checkItemId The id of either an emancipation option or an emancipation category to perform an action on
//  @returns  {array} a jQuery jqXHR object. See https://api.jquery.com/jQuery.ajax/#jqXHR
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if optionId is negative
function saveCheckState (action, checkItemId) {
  // Input check
  if (typeof checkItemId === 'string') {
    const checkItemIdAsNum = parseInt(checkItemId)

    if (!checkItemIdAsNum) {
      throw new TypeError('Param checkItemId is not an integer')
    } else if (checkItemIdAsNum < 0) {
      throw new RangeError('Param checkItemId cannot be negative')
    }
  } else {
    if (!Number.isInteger(checkItemId)) {
      throw new TypeError('Param checkItemId is not an integer')
    } else if (checkItemId < 0) {
      throw new RangeError('Param checkItemId cannot be negative')
    }
  }

  waitForAsyncOperation()

  // Post request
  return $.post(emancipationPage.savePath, {
    check_item_action: action,
    check_item_id: checkItemId
  }).done(function (response, textStatus) {
    if (response.error) {
      resolveAsyncOperation(response.error)
    } else if (response === 'success') {
      resolveAsyncOperation()
    } else {
      resolveAsyncOperation('Unknown response')
    }
  }).fail(function (jqXHR, textStatus, error) {
    resolveAsyncOperation(error)
  })
}

$('document').ready(() => {
  emancipationPage.notifications = $('#async-notifications')
  emancipationPage.asyncSuccessIndicator = emancipationPage.notifications.find('#async-success-indicator')
  emancipationPage.asyncWaitIndicator = emancipationPage.notifications.find('#async-waiting-indicator')

  $('.emancipation-category').click(function () {
    category = $(this)
    categoryCheckbox = category.find('input[type="checkbox"]')
    categoryCollapseIcon = category.find('span')
    categoryCheckboxChecked = categoryCheckbox.is(':checked')

    if (!category.data("disabled")) {
      category.data("disabled", true)
      category.addClass("disabled")
      categoryCheckbox.prop('checked', !categoryCheckboxChecked)
      categoryCheckbox.prop("disabled", "disabled")

      if (categoryCheckboxChecked) {
        saveCheckState('delete_category', categoryCheckbox.val())
        .done(function () {
          category.siblings('.category-options').hide()
          categoryCollapseIcon.text('+')
        })
        .always(function () {
          category.data("disabled", false)
          category.removeClass("disabled")
          categoryCheckbox.prop("disabled", false)
        })
      } else {
        saveCheckState('add_category', categoryCheckbox.val())
        .done(function () {
          category.siblings('.category-options').show()
          categoryCollapseIcon.text('−')
        })
        .always(function () {
          category.data("disabled", false)
          category.removeClass("disabled")
          categoryCheckbox.prop("disabled", false)
        })
      }
    }
  })

  $('.emancipation-radio-button').change(function (data) {
    const thisRadioButton = $(this)

    saveCheckState('set_option', thisRadioButton.val())
  })

  $('.emancipation-option-check-box').change(function () {
    const thisCheckBox = $(this)

    if (thisCheckBox.prop('checked')) {
      saveCheckState('add_option', thisCheckBox.val())
    } else {
      saveCheckState('delete_option', thisCheckBox.val())
    }
  })
})
