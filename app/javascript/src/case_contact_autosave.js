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

      $(`#${formId} :input`).each((_, { id, type, value, checked }) => {
        if (id && type !== 'button' && type !== 'submit') {
          data.push({ id, value, checked })
        }
      })

      $('.casa_case_lock_icon').each((_, obj) => {
        data.push({ id: obj.id, locked: !$(obj).hasClass('fa-lock-open') })
      })

      window.localStorage.setItem(localStorageKey, JSON.stringify(data))
    }

    const loadLockedCasaCases = (id) => {
      const input = document.querySelector(`#${id}`)
      input.classList.remove('fa-lock-open')
      input.classList.add('fa-lock')
      const checkboxId = id.split('-')[1]
      const checkbox = $(`#case_contact_casa_case_id_${checkboxId}`)
      const checkboxLabel = $(`#checkboxDisable-${checkboxId}`)
      checkbox.prop('checked', true).prop('disabled', true)
      checkbox.addClass('disable-checkbox')
      checkboxLabel.addClass('disable-checkbox')
    }

    const load = () => {
      const serializedFormState = window.localStorage.getItem(localStorageKey)
      if (serializedFormState !== null) {
        const formData = JSON.parse(serializedFormState)

        formData.forEach(({ id, value, checked, locked }) => {
          const input = document.querySelector(`#${id}`)
          if (locked === undefined) {
            if (input) {
              input.value = value
            }

            if (!input.checked) {
              input.checked = checked
            }
          } else if (locked) {
            loadLockedCasaCases(id)
          }
        })
      }
    }

    $(`#${formId}`).on('keyup change paste', 'input:not(.casa-case-id), select, textarea', save)
    $('#modal-case-contact-submit').on('click', () => {
      window.localStorage.removeItem(formId)
      window.localStorage.removeItem(localStorageKey)
    })

    $('.casa_case_lock_icon').on('click', (e) => {
      const isOpenIcon = e.target.classList.contains('fa-lock-open')
      e.target.classList.remove(isOpenIcon ? 'fa-lock-open' : 'fa-lock')
      e.target.classList.add(!isOpenIcon ? 'fa-lock-open' : 'fa-lock')
      const id = e.target.id.split('-')[1]
      const checkboxLabel = $(`#checkboxDisable-${id}`)
      const checkbox = $(`#case_contact_casa_case_id_${id}`)
      if (isOpenIcon) checkbox.prop('checked', isOpenIcon)
      isOpenIcon ? checkbox.addClass('disable-checkbox') : checkbox.removeClass('disable-checkbox')
      checkbox.prop('disabled', isOpenIcon)
      isOpenIcon ? checkboxLabel.addClass('disable-checkbox') : checkboxLabel.removeClass('disable-checkbox')
      save()
    })

    document.onload = load()
  }
})
