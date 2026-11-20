/* eslint-env jest, browser */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import PatchNotesController from '../controllers/patch_notes_controller'

const NOTE_HTML = `
  <div class="patch-note-list-item card">
    <div id="patch-note-42" class="card-body" data-patch-note-id="42">
      <textarea disabled>new note text</textarea>
      <select class="note-type-select" disabled><option value="1" selected>Type</option></select>
      <select class="note-group-select" disabled><option value="2" selected>Group</option></select>
      <div class="patch-note-view-buttons">
        <button class="button-edit" data-action="patch-notes#edit"><span class="button-label">Edit</span></button>
        <button class="button-delete" data-action="patch-notes#delete" data-delete-count="0"><span class="button-label">Delete</span></button>
      </div>
      <div class="patch-note-edit-buttons hidden">
        <button class="button-save" data-action="patch-notes#save"><span class="button-label">Save</span></button>
        <button class="button-cancel" data-action="patch-notes#cancel"><span class="button-label">Cancel</span></button>
      </div>
    </div>
  </div>`

const flush = () => new Promise((resolve) => setTimeout(resolve, 0))

describe('patch_notes_controller', () => {
  let application

  const mount = async () => {
    document.head.innerHTML = '<meta name="csrf-token" content="test-token">'
    document.body.innerHTML = `
      <div data-controller="patch-notes" data-patch-notes-path-value="/all_casa_admins/patch_notes">
        <div id="notifications">
          <div class="messages"></div>
          <div id="async-waiting-indicator" style="display: none"></div>
          <div id="async-success-indicator" style="display: none"></div>
        </div>
        <div id="patch-note-list" data-patch-notes-target="list">
          <div class="patch-note-list-item" data-patch-notes-target="newNoteItem">
            <div id="new-patch-note">
              <textarea data-patch-notes-target="newNote"></textarea>
              <select id="new-patch-note-type" data-patch-notes-target="newType"><option value="1">T</option></select>
              <select id="new-patch-note-group" data-patch-notes-target="newGroup"><option value="2">G</option></select>
              <button data-action="patch-notes#create" data-patch-notes-target="createButton">Create</button>
            </div>
          </div>
          ${NOTE_HTML}
        </div>
      </div>`
    application = Application.start()
    application.register('patch-notes', PatchNotesController)
    await flush()
  }

  const okResponse = (body) => ({ ok: true, status: 200, json: async () => body })
  const cardBody = () => document.querySelector('[data-patch-note-id="42"]')

  beforeEach(() => {
    global.fetch = jest.fn()
  })

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
    document.head.innerHTML = ''
  })

  test('create with an empty note warns and does not fetch', async () => {
    await mount()
    document.querySelector('[data-patch-notes-target="createButton"]').click()
    await flush()

    expect(global.fetch).not.toHaveBeenCalled()
    const warning = document.querySelector('.warning-notification')
    expect(warning).not.toBeNull()
    expect(warning.textContent).toContain('Cannot save an empty patch note')
  })

  test('create POSTs JSON and inserts the server-rendered note marked as new', async () => {
    await mount()
    global.fetch.mockResolvedValue(okResponse({ status: 'created', id: 43, html: NOTE_HTML.replaceAll('42', '43').replaceAll('new note text', 'hello world') }))

    document.querySelector('[data-patch-notes-target="newNote"]').value = 'hello world'
    document.querySelector('[data-patch-notes-target="createButton"]').click()
    await flush()
    await flush()

    expect(global.fetch).toHaveBeenCalledTimes(1)
    const [url, options] = global.fetch.mock.calls[0]
    expect(url).toBe('/all_casa_admins/patch_notes')
    expect(options.method).toBe('POST')
    expect(options.headers['X-CSRF-Token']).toBe('test-token')
    expect(JSON.parse(options.body)).toEqual({ note: 'hello world', patch_note_group_id: '2', patch_note_type_id: '1' })

    expect(document.querySelector('[data-patch-notes-target="newNote"]').value).toBe('')
    const inserted = document.querySelector('.patch-note-list-item.new')
    expect(inserted).not.toBeNull()
    expect(inserted.querySelector('textarea').value).toBe('hello world')
    // inserted right after the new-note form, i.e. first among the notes
    expect(document.querySelector('[data-patch-notes-target="newNoteItem"]').nextElementSibling).toBe(inserted)
  })

  test('a failed create shows an error notification and re-enables the form', async () => {
    await mount()
    global.fetch.mockResolvedValue({ ok: false, status: 422, json: async () => ({ errors: '["Note can\'t be blank"]' }) })

    document.querySelector('[data-patch-notes-target="newNote"]').value = 'x'
    const createButton = document.querySelector('[data-patch-notes-target="createButton"]')
    createButton.click()
    await flush()
    await flush()

    const error = document.querySelector('.danger-notification')
    expect(error).not.toBeNull()
    expect(error.textContent).toContain("Note can't be blank")
    expect(createButton.disabled).toBe(false)
    expect(document.querySelector('.patch-note-list-item.new')).toBeNull()
  })

  test('edit enables the inputs and swaps to the save/cancel buttons', async () => {
    await mount()
    document.querySelector('.button-edit').click()

    expect(cardBody().querySelector('textarea').disabled).toBe(false)
    expect(cardBody().querySelector('.note-type-select').disabled).toBe(false)
    expect(cardBody().querySelector('.patch-note-view-buttons').classList.contains('hidden')).toBe(true)
    expect(cardBody().querySelector('.patch-note-edit-buttons').classList.contains('hidden')).toBe(false)
  })

  test('cancel restores the before-edit values and returns to view mode', async () => {
    await mount()
    document.querySelector('.button-edit').click()
    const textarea = cardBody().querySelector('textarea')
    textarea.value = 'unsaved changes'
    document.querySelector('.button-cancel').click()

    expect(textarea.value).toBe('new note text')
    expect(textarea.disabled).toBe(true)
    expect(cardBody().querySelector('.patch-note-view-buttons').classList.contains('hidden')).toBe(false)
    expect(cardBody().querySelector('.patch-note-edit-buttons').classList.contains('hidden')).toBe(true)
  })

  test('save PUTs the edited values and returns to view mode', async () => {
    await mount()
    global.fetch.mockResolvedValue(okResponse({ status: 'ok' }))

    document.querySelector('.button-edit').click()
    const textarea = cardBody().querySelector('textarea')
    textarea.value = 'edited note'
    document.querySelector('.button-save').click()
    await flush()
    await flush()

    const [url, options] = global.fetch.mock.calls[0]
    expect(url).toBe('/all_casa_admins/patch_notes/42')
    expect(options.method).toBe('PUT')
    expect(JSON.parse(options.body).note).toBe('edited note')
    expect(textarea.value).toBe('edited note')
    expect(textarea.disabled).toBe(true)
    expect(cardBody().querySelector('.patch-note-edit-buttons').classList.contains('hidden')).toBe(true)
  })

  test('save with a blank note warns and does not fetch', async () => {
    await mount()
    document.querySelector('.button-edit').click()
    cardBody().querySelector('textarea').value = ''
    document.querySelector('.button-save').click()
    await flush()

    expect(global.fetch).not.toHaveBeenCalled()
    expect(document.querySelector('.warning-notification').textContent).toContain('Cannot save a blank patch note')
  })

  test('delete needs three clicks, then DELETEs and removes the note', async () => {
    await mount()
    global.fetch.mockResolvedValue(okResponse({ status: 'ok' }))

    const deleteButton = document.querySelector('.button-delete')
    deleteButton.click()
    expect(document.querySelector('.warning-notification').textContent).toContain('Click 2 more times to delete')
    expect(deleteButton.querySelector('.button-label').textContent).toBe('2')
    expect(global.fetch).not.toHaveBeenCalled()

    deleteButton.click()
    expect(deleteButton.querySelector('.button-label').textContent).toBe('1')
    expect(global.fetch).not.toHaveBeenCalled()

    deleteButton.click()
    await flush()
    await flush()

    const [url, options] = global.fetch.mock.calls[0]
    expect(url).toBe('/all_casa_admins/patch_notes/42')
    expect(options.method).toBe('DELETE')
    expect(document.querySelector('[data-patch-note-id="42"]')).toBeNull()
  })
})
