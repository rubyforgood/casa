/* global $ */

$(() => { // JQuery's callback for the DOM loading
  const formId = 'casa-contact-form'
  let localStorageKey = formId

  if ($('.case_contacts-new').length > 0 || $('.case_contacts-edit').length > 0) {
    if ($('.case_contacts-edit').length > 0) {
      const caseContactId = $(`#${formId}`)[0].action.split('/').pop()
      localStorageKey = `${formId}-${caseContactId}`
    }

    const save = () => {
      const data = []

      $(`#${formId} :input`).each((_, { id, type, value, checked } /* javascript destructuring assignment */) => {
        if (id && type !== 'button' && type !== 'submit') {
          data.push({ id, value, checked })
        }
      })

      window.localStorage.setItem(localStorageKey, JSON.stringify(data))
    }

    const load = () => {
      const serializedFormState = window.localStorage.getItem(localStorageKey)
      if (serializedFormState !== null) {
        const formData = JSON.parse(serializedFormState)

        formData.forEach(({ id, value, checked }) => {
          const input = document.querySelector(`#${id}`)

          if (input && !(/checkbox|hidden|image|radio|reset|submit/.test(input.type))) {
            input.value = value
          }

          if (!input.checked) {
            input.checked = checked
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
