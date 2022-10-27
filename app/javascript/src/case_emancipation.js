/* eslint-env jquery */
/* global $ */

const Notifier = require('./async_notifier')
const TypeChecker = require('./type_checker')

const emancipationPage = {
  savePath: window.location.pathname + '/save'
}

// Called when an async operation completes. May show notifications describing how the operation completed
//  @param    {string | Error=}  error The error to be displayed(optional)
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {Error}      for trying to resolve more async operations than the amount currently awaiting
function resolveAsyncOperation (error) {
  if (error instanceof Error) {
    error = error.message
  }

  emancipationPage.notifier.stopAsyncOperation(error)
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
    checkItemId = parseInt(checkItemId)
  }

  TypeChecker.checkPositiveInteger(checkItemId, 'checkItemId')

  emancipationPage.notifier.startAsyncOperation()

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
  if (!((/casa_cases\/[A-Za-z\-0-9]+\/emancipation/).test(window.location.pathname))) {
    return
  }

  const asyncNotificationsElement = $('#async-notifications')
  emancipationPage.notifier = new Notifier(asyncNotificationsElement)

  $('.emancipation-category').click(function () {
    const category = $(this)
    const categoryCheckbox = category.find('input[type="checkbox"]')
    const categoryCollapseIcon = category.find('span')
    const categoryCheckboxChecked = categoryCheckbox.is(':checked')
    const categoryOptionsContainer = category.siblings('.category-options')

    if (!category.data('disabled')) {
      category.data('disabled', true)
      category.addClass('disabled')
      categoryCheckbox.prop('disabled', 'disabled')

      let saveAction,
        collapseIcon,
        doneCallback

      if (categoryCheckboxChecked) {
        collapseIcon = '+'
        doneCallback = () => {
          categoryOptionsContainer.hide()

          // Uncheck all category options
          categoryOptionsContainer.children().filter(function () {
            return $(this).find('input').prop('checked')
          }).each(function () {
            const checkbox = $(this).find('input')

            checkbox.prop('checked', false)
            emancipationPage.notifier.notify('Unchecked ' + checkbox.next().text(), 'info')
          })
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

  $('.check-item').click(function () {
    const checkComponent = $(this)
    const checkElement = checkComponent.find('input')

    if (checkComponent.data('disabled')) {
      return
    }

    if (checkElement.attr('type') === 'radio') {
      if (checkElement.prop('checked')) {
        return
      }

      const radioButtons = checkComponent.parent().children()

      radioButtons.each(function () {
        const radioComponent = $(this)
        const radioInput = radioComponent.find('input')

        radioComponent.data('disabled', true)
        radioComponent.addClass('disabled')
        radioInput.prop('disabled', 'disabled')
      })

      saveCheckState('set_option', checkElement.val())
        .done(function () {
          checkElement.prop('checked', true)
          radioButtons.each(function () {
            const radioComponent = $(this)
            const radioInput = radioComponent.find('input')

            radioComponent.data('disabled', false)
            radioComponent.removeClass('disabled')
            radioInput.prop('disabled', false)
          })
        })
    } else { // Expecting type=checkbox
      checkComponent.data('disabled', true)
      checkComponent.addClass('disabled')
      checkElement.prop('disabled', 'disabled')

      const originallyChecked = checkElement.prop('checked')
      let asyncCall

      if (!originallyChecked) {
        asyncCall = saveCheckState('add_option', checkElement.val())
      } else {
        asyncCall = saveCheckState('delete_option', checkElement.val())
      }

      asyncCall.done(function () {
        checkComponent.data('disabled', false)
        checkComponent.removeClass('disabled')
        checkElement.prop('checked', !originallyChecked)
        checkElement.prop('disabled', false)
      })
    }
  })
})
