/* global $ */
$(() => { // JQuery's callback for the DOM loading
  const validatedFormCollection = $('.component-validated-form')

  validatedFormCollection.on('submit', function (e) {
    const form = $(this)
    let valid = true

    form.find('.component-date-picker-range').each(function () {
      const thisDatePickerRangeAsJQuery = $(this)
      const maxDateValue = thisDatePickerRangeAsJQuery.attr('data-max-date')
      const minDateValue = thisDatePickerRangeAsJQuery.attr('data-min-date')

      const max = maxDateValue === 'today' ? new Date() : new Date(maxDateValue)
      const min = minDateValue === 'today' ? new Date() : new Date(minDateValue)

      const setDate = new Date(thisDatePickerRangeAsJQuery.val())

      if (setDate > max && !isNaN(max)) {
        valid = false
      } else if (setDate < min && !isNaN(min)) {
        valid = false
      }
    })

    if (!valid) {
      e.preventDefault()
    }
  })
})
