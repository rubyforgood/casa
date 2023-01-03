/* global $ */

$(() => {
  const formId = 'casa-contact-form'
  let localStorageKey = formId

  if ($('.case_contacts-new').length > 0 || $('.case_contacts-edit').length > 0) {
    if ($('.case_contacts-edit').length > 0) {
      const caseContactId = $(`#${formId}`)[0].action.split('/').pop()
      localStorageKey = `${formId}-${caseContactId}`
    }
    const save = () => {
      const data = []

      $(`#${formId} :input`).each((_, { id, type, value, checked }) => {
        if (id && type !== 'button' && type !== 'submit') {
          data.push({ id, value, checked })
        }
      })

      window.localStorage.setItem(localStorageKey, JSON.stringify(data))
    }

    const load = () => {
      const rawData = window.localStorage.getItem(localStorageKey)
      if (rawData !== null) {
        const data = JSON.parse(rawData)

        data.forEach(({ id, value, checked }) => {
          const element = document.querySelector(`#${id}`)

          if (element) {
            element.value = value
          }
          if (!element.checked) {
            element.checked = checked
          }
        })
      }
    }

    $(`#${formId}`).on('keyup change paste', 'input, select, textarea', save)
    $('#modal-case-contact-submit').on('click', () => {
      window.localStorage.removeItem(formId)
      window.localStorage.removeItem(localStorageKey)
    })

    document.onload = load()
  }
})
