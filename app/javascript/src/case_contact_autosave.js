
$('document').ready(() => {
  if ($('.case_contacts-new').length > 0) {
    const formId = 'casa-contact-form' // ID of the form
    const url = window.location.href // href for the page
    const formIdentifier = `${url} ${formId}` // Identifier used to identify the form
    const saveButton = document.querySelector('#case-contact-save') // select save button
    const alertBox = document.querySelector('#case-contact-draft-alerts') // select alert display div
    // const form = document.querySelector(`#${formId}`) // select form
    // let formElements = form.elements; // get the elements in the form
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
  }
})
