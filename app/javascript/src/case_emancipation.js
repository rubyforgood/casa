const emancipationPage = {
  saveOperationSuccessful: false,
  savePath: window.location.pathname + '/save',
  waitingSaveOperationCount: 0
}

// Shows an error notification
//  @param    {string}  message The message to be displayed
//  @param    {string}  level One of the following logging levels
//    "error"  Shows a red notification
//    "info"   Shows a green notification
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} for unsupported logging levels
function notify (message, level) {
  if (typeof message !== 'string') {
    throw new TypeError('Param message must be a string')
  }

  switch (level) {
    case 'error':
      emancipationPage.notifications.append(`
        <div class="async-failure-indicator">
          Error: ${message}
          <button class="btn btn-danger btn-sm">×</button>
        </div>`)
        .find('.async-failure-indicator button').click(function () {
          $(this).parent().remove()
        })
      break
    case 'info':
      emancipationPage.notifications.append(`
        <div class="async-success-indicator">
          ${message}
          <button class="btn btn-success btn-sm">×</button>
        </div>`)
        .find('.async-success-indicator button').click(function () {
          $(this).parent().remove()
        })

      break
    default:
      throw new RangeError('Unsupported option for param level')
      break
  }
}

// Called when an async operation completes. May show notifications describing how the operation completed
//  @param    {string | Error=}  error The error to be displayed(optional)
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
    notify(error, 'error')
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
//  @param    {string}  action One of the following:
//    'add_category'    to add a category to the case
//    'add_option'      to add an option to the case
//    'delete_category' to remove a category from the case
//    'delete_option'   to remove an option from the case
//    'set_option'      to set the option for a mutually exclusive category
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
  })
    .then(function (response, textStatus, jqXHR) {
      if (response.error) {
        return $.Deferred().reject(jqXHR, textStatus, response.error)
      } else if (response === 'success') {
        resolveAsyncOperation()
      } else {
        resolveAsyncOperation('Unknown response')
      }

      return response
    })
    .fail(function (jqXHR, textStatus, error) {
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
    categoryOptionsContainer = category.siblings('.category-options')

    if (!category.data('disabled')) {
      category.data('disabled', true)
      category.addClass('disabled')
      categoryCheckbox.prop('disabled', 'disabled')

      let saveAction,
        collapseIcon,
        doneCallback

      if (categoryCheckboxChecked) {
        // Uncheck all category options
        categoryOptionsContainer.children().filter(function () {
          return $(this).prop('checked')
        }).each(function () {
          const checkbox = $(this)

          checkbox.prop('checked', false)
          saveCheckState('delete_option', checkbox.val())
            .fail(function () {
              checkbox.prop('checked', false)
            })
          notify('Unchecked ' + checkbox.next().text(), 'info')
        })

        collapseIcon = '+'
        doneCallback = () => {
          categoryOptionsContainer.hide()
        }
        saveAction = 'delete_category'
      } else {
        collapseIcon = '−'
        doneCallback = () => {
          categoryOptionsContainer.show()
        }
        saveAction = 'add_category'
      }

      saveCheckState(saveAction, categoryCheckbox.val())
        .done(function () {
          doneCallback()
          categoryCheckbox.prop('checked', !categoryCheckboxChecked)
          categoryCollapseIcon.text(collapseIcon)
        })
        .always(function () {
          category.data('disabled', false)
          category.removeClass('disabled')
          categoryCheckbox.prop('disabled', false)
        })
    }
  })

  $('.emancipation-radio-button').change(function (data) {
    const thisRadioButton = $(this)

    saveCheckState('set_option', thisRadioButton.val())
      .fail(function () {
        thisRadioButton.prop('checked', false)
      })
  })

  $('.emancipation-option-check-box').change(function () {
    const thisCheckBox = $(this)

    const originallyChecked = thisCheckBox.prop('checked')
    let asyncCall

    if (originallyChecked) {
      asyncCall = saveCheckState('add_option', thisCheckBox.val())
    } else {
      asyncCall = saveCheckState('delete_option', thisCheckBox.val())
    }

    asyncCall.fail(function () {
      thisCheckBox.prop('checked', originallyChecked)
    })
  })
})
