
$('document').ready(() => {
  if ($('.case_contacts-new').length > 0) {
    const formId = 'casa-contact-form' // ID of the form
    const form = document.querySelector('#casa-contact-form')
    const formIdentifier = `${formId}` // Identifier used to identify the form
    const saveButton = document.querySelector('#case-contact-save') // select save button
    const alertBox = document.querySelector('#case-contact-draft-alerts') // select alert display div
    const caseNotes = document.querySelector('#case_contact_notes')

    saveButton.onclick = event => {
      event.preventDefault()
      const data = {}
      data[formIdentifier] = caseNotes.value
      window.localStorage.setItem(formIdentifier, JSON.stringify(data[formIdentifier]))
      const message = 'Form draft has been saved!'
      displayAlert(message)
    }

    const displayAlert = message => {
      alertBox.innerText = message // add the message into the alert box
      alertBox.style.display = 'block' // make the alert box visible
      setTimeout(function () {
        alertBox.style.display = 'none' // hide the alert box after 1 second
      }, 5000)
    }

    const populateForm = () => {
      if (window.localStorage.key(formIdentifier)) {
        const savedData = JSON.parse(window.localStorage.getItem(formIdentifier)) // get and parse the saved data from localStorage
        caseNotes.value = savedData
        const message = 'Form has been refilled with saved data!'
        displayAlert(message)
      }
    }
    document.onload = populateForm() // populate the form when the document is loaded

    form.onsubmit = event => {
      window.localStorage.removeItem(formIdentifier)
    }
  }
})
