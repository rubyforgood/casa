// https://www.stimulus-components.com/docs/stimulus-rails-nested-form/
import NestedForm from '@stimulus-components/rails-nested-form'

// Connects to data-controller="casa-nested-form"
// Allows nested forms to be used with autosave controller, adding and deleting records
//   so that autosave updates do not create/destroy nested records multiple times.
// add() & remove() are kept standard, can be used without autosave just fine:
//   no values are necessary in that case.
// Created for the CaseContact form, see its usage there.
export default class extends NestedForm {
  static values = {
    route: String, // path to create/destroy a record, e.g. "/contact_topic_answers"
    parentName: String, // snake case name of parent model, e.g. "case_contact"
    parentId: Number, // id of record this form is nested within e.g. @case_contact.id
    modelName: String, // name of nested form, e.g. "contact_topic_answer"
    requiredFields: { // fields required (belongs_to etc...) to pass validation (e.g. contact_topic_id)
      type: Array, default: []
    }
  }

  connect () {
    super.connect()

    const headers = new Headers()
    headers.append('Content-Type', 'application/json')
    headers.append('Accept', 'application/json')
    const tokenTag = document.querySelector('meta[name="csrf-token"]')
    if (tokenTag) { // does not exist in test environment
      headers.append('X-CSRF-Token', tokenTag.content)
    }
    this.headers = headers
  }

  /* Adds item to the form. Item will not be created until form submission. */
  add = (e) => {
    super.add(e)
  }

  /* Creates a new record for the added item (before submission). */
  addAndCreate = (e) => {
    this.add(e)
    const items = this.element.querySelectorAll(this.wrapperSelectorValue)
    const addedItem = items[items.length - 1]
    const childIndex = addedItem.dataset.childIndex

    const itemBase = `${this.parentNameValue}_${this.modelNameValue}s_attributes_${childIndex}`

    const fields = {}
    fields[`${this.parentNameValue}_id`] = this.parentIdValue

    this.requiredFieldsValue.forEach(field => {
      const fieldId = `${itemBase}_${field}`
      const fieldEl = document.querySelector(`#${fieldId}`)
      if (!fieldEl) {
        console.warn('Aborting: Field not found:', fieldId)
        return
      }
      fields[field] = fieldEl.value
    })

    if (Object.values(fields).some(value => value === '')) {
      console.warn('Aborting: Required field empty:', fields)
      return
    }

    const body = {}
    body[this.modelNameValue] = fields

    fetch(this.routeValue, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify(body)
    })
      .then(response => {
        if (response.ok) {
          return response.json()
        } else {
          return Promise.reject(response)
        }
      })
      .then(data => {
        const idAttr = `${itemBase}_id`
        const idField = document.querySelector(`#${idAttr}`)
        idField.setAttribute('value', data.id)
        addedItem.dataset.newRecord = false
        addedItem.dataset.recordId = data.id
      })
      .catch(error => {
        console.error(error.status, error.statusText)
        error.json().then(errorJson => {
          console.error('errorJson', errorJson)
        })
      })
  }

  /* Removes item from the form. Will not destroy record until form submission. */
  remove (e) {
    super.remove(e)
  }

  /* Destroys a record when removing the item (before submission). */
  destroyAndRemove = (e) => {
    const wrapper = e.target.closest(this.wrapperSelectorValue)
    const recordId = wrapper.dataset.recordId
    if (wrapper.dataset.newRecord === 'false' && (recordId.length > 0)) {
      fetch(`${this.routeValue}/${recordId}`, {
        method: 'DELETE',
        headers: this.headers
      })
        .then(response => {
          if (response.ok) {
            // deleted from db; update as non-persisted, remove as usual.
            wrapper.dataset.newRecord = true
            wrapper.dataset.recordId = ''
            this.remove(e)
          } else {
            return Promise.reject(response)
          }
        })
        .catch(error => {
          console.error(error.status, error.statusText)
          error.json().then(errorJson => {
            console.error('errorJson', errorJson)
          })
        })
    } else {
      console.warn(
        'Not enough information to destroy record:', {
          wrapperDatasetNewRecord: wrapper.dataset.newRecord,
          recordId
        }
      )
      this.remove(e) // treat as typical removal
    }
  }

  windowConfirmRemove (e) {
    const text = 'Are you sure you want to remove this item?'
    if (window.confirm(text)) {
      this.remove(e)
    }
  }

  windowConfirmDestroyAndRemove (e) {
    const text = 'Are you sure you want to remove this item?'
    if (window.confirm(text)) {
      this.destroyAndRemove(e)
    }
  }
}
