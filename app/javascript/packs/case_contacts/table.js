import axios from 'axios';

document.addEventListener('DOMContentLoaded', () => {
  const CaseSelector = document.querySelector('#select-case-number')

  CaseSelector.addEventListener('change', () => {
    const SelectedCaseId = CaseSelector.querySelectorAll('option')[CaseSelector.selectedIndex].dataset.id

    axios.get(`/casa_cases/${SelectedCaseId}.json`).then(response => {
      document.querySelector('#case-court-date').innerText = response.data['court_date']
      document.querySelector('#case-court-report-due-date').innerText = response.data['court_report_due_date']
      document.querySelector('#case-court-report-status').innerText = response.data['court_report_status']

      generateCaseContactsHTML(response.data['case_contacts'])
      generateCaseYouthIcon(response.data['transition_aged_youth'])
    })
  })
})

const generateCaseContactsHTML = (case_contacts) => {
  document.querySelector('#case-contacts').innerHTML = ''

  case_contacts.forEach(contact => {
    document.querySelector('#case-contacts').innerHTML += generateContactHTMLFromContact(contact)
  })
}

const generateContactHTMLFromContact = contact => {
  return `<article class="case-contact-item">
    <header class="flex top contact-article">
      <section>
        <h2>${contact['medium_type']}</h2>
        <p>
          Foster Parent |
          ${contact['occurred_at']} |
          ${contact['duration_minutes']} minutes |
          ${contact['miles_driven']} miles driven |
          Reimbursement: ${contact['want_driving_reimbursement']}
        </p>
      </section>
      <button class="button page">Edit</button>
    </header>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean euismod bibendum laoreet. Proin gravida dolor sit <a class="read-more-link" href="#">Read More</a>
    </p>
    <div class="followup-alert">
      <img src="/followup-alert.svg" alt="" />
      <section>
        <h3>Follow-Up</h3>
        <p>Nam fermentum, nulla luctus pharetra vulputate</p>
        <a href="#">+ Follow-Up Contact</a>
      </section>
    </div>
  </article>`
}

const generateCaseYouthIcon = transitionAgedYouth => {
  if(transitionAgedYouth) {
    document.querySelector('#case-youth-icon').innerHTML = '<img alt="Non transition aged youth (under 14)" src="/caterpillar.svg" class="youth-icon caterpillar">'
  }
  else {
    document.querySelector('#case-youth-icon').innerHTML = '<img alt="Transition aged youth (over 14)" src="/butterfly.svg" class="youth-icon butterfly">'
  }
}
