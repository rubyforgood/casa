// The case-contact form no longer has a record behind it when it loads: nothing is inserted until the
// first real save, so an abandoned "New case contact" click leaves nothing behind. The id therefore
// only exists after the first successful save, and everything that needs one -- the autosave, and the
// contact-topic checklist, which POSTs an answer the moment a topic is checked -- goes through here so
// there is exactly ONE creation path. Two would race and insert two drafts.

let inFlight = null

// Point the form (and anything keyed on the id) at the record that now exists. Without this the next
// save would POST to create again and insert a second draft.
function adopt (form, data) {
  form.action = data.form_action
  form.dataset.caseContactId = data.id

  // Rails routes the wizard step as PATCH, and the autosave always fetches with POST, so the override
  // has to travel in the body the way a persisted-record form would send it.
  let method = form.querySelector('input[name="_method"]')
  if (!method) {
    method = document.createElement('input')
    method.type = 'hidden'
    method.name = '_method'
    form.appendChild(method)
  }
  method.value = 'patch'

  // Stimulus values are reactive, so writing the attribute is enough for the contact-topics
  // controller to pick up the new id.
  const topics = document.querySelector('[data-controller~="contact-topics"]')
  if (topics) { topics.setAttribute('data-contact-topics-case-contact-id-value', data.id) }

  // Same for the nested expense rows, which POST an AdditionalExpense against the parent id.
  document.querySelectorAll('[data-controller~="casa-nested-form"]').forEach(nested => {
    nested.setAttribute('data-casa-nested-form-parent-id-value', data.id)
  })

  // The Discard control is server-rendered on `persisted?`, so it ships hidden on a new form. Point
  // its button_to at the record and reveal it -- otherwise it stays invisible until a reload.
  const discard = document.getElementById('discard-draft')
  if (discard && data.discard_path) {
    const discardForm = discard.querySelector('form')
    if (discardForm) { discardForm.action = data.discard_path }
    discard.classList.remove('hidden')
  }

  // Leave the browser on the draft's own URL so a refresh resumes it instead of starting over.
  if (window.history && window.history.replaceState) {
    window.history.replaceState({}, '', data.form_action)
  }
}

export function isPersisted (form) {
  return Boolean(form.dataset.caseContactId)
}

// Create the record from the form's current contents, adopt the id, and resolve with it. Concurrent
// callers share the single request.
export function ensureCaseContact (form) {
  if (isPersisted(form)) { return Promise.resolve(form.dataset.caseContactId) }
  if (inFlight) { return inFlight }

  inFlight = window.fetch(form.action, {
    method: 'POST',
    headers: { Accept: 'application/json' },
    body: new FormData(form) // eslint-disable-line no-undef
  }).then(response => {
    if (!response.ok) { return Promise.reject(response) }
    return response.json()
  }).then(data => {
    adopt(form, data)
    inFlight = null
    return data.id
  }).catch(error => {
    inFlight = null
    return Promise.reject(error)
  })

  return inFlight
}
