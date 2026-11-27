/* eslint-env jest */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import CsvImportController from '../controllers/csv_import_controller'

// jsdom has no DataTransfer and only accepts a real FileList for input.files, so fake both.
class FakeDataTransfer {
  constructor () {
    this.files = []
    this.items = { add: (file) => this.files.push(file) }
  }
}

const setFiles = (input, files) => {
  let current = files
  Object.defineProperty(input, 'files', { configurable: true, get: () => current, set: (value) => { current = value } })
}

const form = (withOptIn = false) => `
  <form data-controller="csv-import" data-action="submit->csv-import#guard">
    <input type="file" id="volunteer-file" data-csv-import-target="input" data-action="change->csv-import#store">
    ${withOptIn ? '<div id="smsOptIn" data-csv-import-target="optIn"></div>' : ''}
    <button type="submit">Import</button>
    <p id="volunteer-import-error" data-csv-import-target="error" class="hidden"></p>
  </form>`

const storedCsv = JSON.stringify({ name: 'volunteers.csv', data: `data:text/csv;base64,${window.btoa('display_name,email\n')}` })

describe('csv_import_controller', () => {
  let application

  // Mounts the form; beforeConnect runs after the DOM exists but before the controller connects.
  const mount = async (html, beforeConnect = () => {}) => {
    document.body.innerHTML = html
    beforeConnect(document.getElementById('volunteer-file'))
    application = Application.start()
    application.register('csv-import', CsvImportController)
    await new Promise((resolve) => setTimeout(resolve, 0))
    return document.getElementById('volunteer-file')
  }

  beforeEach(() => {
    window.DataTransfer = FakeDataTransfer
  })

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
    window.localStorage.clear()
    delete window.DataTransfer
  })

  test('blocks submit and shows the error when no file is chosen', async () => {
    const input = await mount(form(), (el) => setFiles(el, []))
    const event = new window.Event('submit', { bubbles: true, cancelable: true })
    document.querySelector('form').dispatchEvent(event)

    expect(event.defaultPrevented).toBe(true)
    expect(document.getElementById('volunteer-import-error').classList).not.toContain('hidden')
    expect(document.activeElement).toBe(input)
  })

  test('allows submit when a file is chosen', async () => {
    await mount(form(), (el) => setFiles(el, [new window.File(['a'], 'a.csv')]))
    const event = new window.Event('submit', { bubbles: true, cancelable: true })
    document.querySelector('form').dispatchEvent(event)

    expect(event.defaultPrevented).toBe(false)
  })

  test('stores the chosen file in localStorage and hides the error', async () => {
    const input = await mount(form(), (el) => setFiles(el, []))
    document.getElementById('volunteer-import-error').classList.remove('hidden')

    setFiles(input, [new window.File(['display_name,email\n'], 'volunteers.csv', { type: 'text/csv' })])
    input.dispatchEvent(new window.Event('change'))
    await new Promise((resolve) => setTimeout(resolve, 50))

    const stored = JSON.parse(window.localStorage.getItem('volunteer-file'))
    expect(stored.name).toBe('volunteers.csv')
    expect(stored.data).toMatch(/^data:text\/csv;base64,/)
    expect(document.getElementById('volunteer-import-error').classList).toContain('hidden')
  })

  test('restores the stored file when the SMS opt-in step is shown, then clears it', async () => {
    window.localStorage.setItem('volunteer-file', storedCsv)
    const input = await mount(form(true), (el) => setFiles(el, []))

    expect(input.files).toHaveLength(1)
    expect(input.files[0].name).toBe('volunteers.csv')
    const reader = new window.FileReader()
    const text = new Promise((resolve) => { reader.onload = () => resolve(reader.result) })
    reader.readAsText(input.files[0])
    expect(await text).toBe('display_name,email\n')
    expect(window.localStorage.getItem('volunteer-file')).toBeNull()
  })

  test('clears a corrupt stored value without throwing', async () => {
    window.localStorage.setItem('volunteer-file', 'not json')
    const input = await mount(form(true), (el) => setFiles(el, []))

    expect(input.files).toHaveLength(0)
    expect(window.localStorage.getItem('volunteer-file')).toBeNull()
  })

  test('clears the stored file without restoring it when the SMS opt-in step is not shown', async () => {
    window.localStorage.setItem('volunteer-file', storedCsv)
    const input = await mount(form(), (el) => setFiles(el, []))

    expect(input.files).toHaveLength(0)
    expect(window.localStorage.getItem('volunteer-file')).toBeNull()
  })
})
