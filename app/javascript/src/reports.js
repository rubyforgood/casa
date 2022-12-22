document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', (event) => {
    if (event.target.matches('.report-form-submit')) {
      return handleReportFormSubmit(event)
    }
  })
})

const handleReportFormSubmit = (event) => {
  event.preventDefault()

  const buttonText = event.target.innerHTML

  event.target.disabled = 'disabled'
  event.target.value = event.target.dataset.disableWith
  event.target.form.submit()

  setTimeout(() => {
    event.target.disabled = false
    event.target.value = buttonText
  }, 3000)
}
