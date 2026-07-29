/* eslint-env jest */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import LocalStorageResetController from '../controllers/local_storage_reset_controller'

describe('local_storage_reset_controller', () => {
  let application

  const mount = async (html) => {
    document.body.innerHTML = html
    application = Application.start()
    application.register('local-storage-reset', LocalStorageResetController)
    await new Promise((resolve) => setTimeout(resolve, 0))
  }

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
    window.localStorage.clear()
  })

  test('removes the configured key on connect', async () => {
    window.localStorage.setItem('casa-contact-form', 'draft')
    await mount('<div data-controller="local-storage-reset" data-local-storage-reset-key-value="casa-contact-form"></div>')
    expect(window.localStorage.getItem('casa-contact-form')).toBeNull()
  })

  test('leaves other keys untouched', async () => {
    window.localStorage.setItem('keep-me', 'yes')
    await mount('<div data-controller="local-storage-reset" data-local-storage-reset-key-value="casa-contact-form"></div>')
    expect(window.localStorage.getItem('keep-me')).toBe('yes')
  })
})
