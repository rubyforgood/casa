/* global $ */

$(() => {
  const formId = 'casa-contact-form'

  if ($('.case_contacts-new').length > 0) {
    const save = () => {
      const data = []

      $(`#${formId} :input`).each((_, { id, type, value, checked }) => {
        if (id && type !== 'button' && type !== 'submit') {
          data.push({ id, value, checked })
        }
      })

      window.localStorage.setItem(formId, JSON.stringify(data))
    }

    const load = () => {
      if (window.localStorage.key(formId)) {
        const data = JSON.parse(window.localStorage.getItem(formId))

        data.forEach(({ id, value, checked }) => {
          const element = document.querySelector(`#${id}`)

          if (element) {
            element.value = value
            element.checked = checked
          }
        })
      }
    }

    $(`#${formId}`).on('keyup change paste', 'input, select, textarea', save)

    document.onload = load()
  }

  if (/\/casa_cases\/.*\d+\/$/.test(window.location.pathname)) {
    window.localStorage.removeItem(formId)
  }
})
