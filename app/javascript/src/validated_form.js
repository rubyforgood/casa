/* global $ */
$(() => { // JQuery's callback for the DOM loading
  const validatedFormCollection = $('.component-validated-form')

  validatedFormCollection.on('submit', function (e) {
    e.preventDefault()

    const form = this
    let valid = true

    console.log('Test')

    this.children('.component-date-picker-range').each(function () {
      const maxDateValue = this.attr('data-max_date')
      const minDateValue = this.attr('data-min_date')

      const max = maxDateValue === 'today' ? new Date() : new Date(maxDateValue)
      const min = minDateValue === 'today' ? new Date() : new Date(minDateValue)

      const setDate = new Date(this.val())

      if (setDate > max) {
        valid = false
      } else if (setDate < min) {
        valid = false
      }
    })

    if (valid) {
      form.submit()
    }
  })
})
