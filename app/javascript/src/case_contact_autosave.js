$('document').ready(() => {
  const formId = 'casa-contact-form'

  if ($('.case_contacts-new').length > 0) {
    const caseNotes = document.querySelector('#case_contact_notes')

    const populateForm = () => {
      if (window.localStorage.key(formId)) {
        const savedData = JSON.parse(window.localStorage.getItem(formId)) // get and parse the saved data from localStorage
        caseNotes.value = savedData
      }
    }

    const autoSave = () => {
      setInterval(function () {
        const data = {}
        data[formId] = caseNotes.value
        window.localStorage.setItem(formId, JSON.stringify(data[formId]))
      }, 5000)
    }

    document.onload = autoSave()
    document.onload = populateForm() // populate the form when the document is loaded
  }

  if (/\/casa_cases\/\d+$/.test(window.location.pathname)) {
    window.localStorage.removeItem(formId)
  }
})
