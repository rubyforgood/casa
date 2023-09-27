/* eslint-env jquery */
/* global $ */

const Notifier = require('./notifier')
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
//    "add_category"    to add a category to the case
//    "add_option"      to add an option to the case
//    "delete_category" to remove a category from the case
//    "delete_option"   to remove an option from the case
//    "set_option"      to set the option for a mutually exclusive category
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

export class Toggler {
  constructor (emancipationCategory) {
    this.emancipationCategory = emancipationCategory
    this.categoryCollapseIcon = this.emancipationCategory.find('.category-collapse-icon')
    this.categoryOptionsContainer = this.emancipationCategory.next('.category-options')
  }

  manageTogglerText () {
    if (this.emancipationCategory.attr('data-is-open') === 'true') {
      this.categoryCollapseIcon.text('–')
    } else if (this.emancipationCategory.attr('data-is-open') === 'false') {
      this.categoryCollapseIcon.text('+')
    }
  }

  openChildren () {
    this.categoryOptionsContainer.show()
    this.emancipationCategory.attr('data-is-open', 'true')
  }

  closeChildren () {
    this.categoryOptionsContainer.hide()
    this.emancipationCategory.attr('data-is-open', 'false')
  }

  deselectChildren (notifierCallback) {
    this.categoryOptionsContainer.children().filter(function () {
      return $(this).find('input').prop('checked')
    }).each(function () {
      const checkbox = $(this).find('input')

      checkbox.prop('checked', false)
      notifierCallback(checkbox.next().text())
    })
  }
}

$(() => { // JQuery's callback for the DOM loading
  if (!((/casa_cases\/[A-Za-z\-0-9]+\/emancipation/).test(window.location.pathname))) {
    return
  }

  const notificationsElement = $('#notifications')
  emancipationPage.notifier = new Notifier(notificationsElement)

  $('.category-collapse-icon').on('click', function () {
    const categoryCollapseIcon = $(this)
    const emancipationCategory = categoryCollapseIcon.parent()
    const toggler = new Toggler(emancipationCategory)

    if (emancipationCategory.attr('data-is-open') === 'true') {
      toggler.closeChildren()
      toggler.manageTogglerText()
    } else if (emancipationCategory.attr('data-is-open') === 'false') {
      toggler.openChildren()
      toggler.manageTogglerText()
    }
  })

  $('.emacipation-category-input-label-pair').on('click', function () {
    const emacipationCategoryInputLabelPair = $(this)
    const emancipationCategory = emacipationCategoryInputLabelPair.parent()
    const toggler = new Toggler(emancipationCategory)
    const categoryCheckbox = emancipationCategory.find('.emancipation-category-check-box')
    const categoryCheckboxChecked = categoryCheckbox.is(':checked')

    if (!emancipationCategory.data('disabled')) {
      emancipationCategory.data('disabled', true)
      emancipationCategory.addClass('disabled')
      categoryCheckbox.prop('disabled', 'disabled')

      let saveAction,
        doneCallback

      if (categoryCheckboxChecked) {
        doneCallback = () => {
          toggler.manageTogglerText()
          toggler.deselectChildren((text) => emancipationPage.notifier.notify('Unchecked ' + text, 'info'))
        }
        saveAction = 'delete_category'
      } else {
        doneCallback = () => {
          toggler.openChildren()
          toggler.manageTogglerText()
        }
        saveAction = 'add_category'
      }

      saveCheckState(saveAction, categoryCheckbox.val())
        .done(function () {
          doneCallback()
          categoryCheckbox.prop('checked', !categoryCheckboxChecked)
          toggler.manageTogglerText()
        })
        .always(function () {
          emancipationCategory.data('disabled', false)
          emancipationCategory.removeClass('disabled')
          categoryCheckbox.prop('disabled', false)
        })
    }
  })

  $('.check-item').on('click', function () {
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
