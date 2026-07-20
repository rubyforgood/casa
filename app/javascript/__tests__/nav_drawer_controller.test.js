/* eslint-env jest, browser */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import NavDrawerController from '../controllers/nav_drawer_controller'

describe('nav_drawer_controller', () => {
  let application

  const mount = async () => {
    document.body.innerHTML = `
      <div data-controller="nav-drawer" data-action="keydown.esc@window->nav-drawer#close">
        <div data-nav-drawer-target="backdrop" class="hidden" data-action="click->nav-drawer#close"></div>
        <aside data-nav-drawer-target="sidebar" class="-translate-x-full"></aside>
        <button data-nav-drawer-target="button" aria-expanded="false" data-action="click->nav-drawer#toggle"></button>
      </div>`
    application = Application.start()
    application.register('nav-drawer', NavDrawerController)
    await new Promise((resolve) => setTimeout(resolve, 0))
  }

  const els = () => ({
    backdrop: document.querySelector('[data-nav-drawer-target="backdrop"]'),
    sidebar: document.querySelector('[data-nav-drawer-target="sidebar"]'),
    button: document.querySelector('[data-nav-drawer-target="button"]')
  })

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
    document.body.classList.remove('overflow-hidden')
  })

  test('the toggle button opens the drawer', async () => {
    await mount()
    const { backdrop, sidebar, button } = els()
    button.click()
    expect(sidebar.classList.contains('-translate-x-full')).toBe(false)
    expect(backdrop.classList.contains('hidden')).toBe(false)
    expect(button.getAttribute('aria-expanded')).toBe('true')
    expect(document.body.classList.contains('overflow-hidden')).toBe(true)
  })

  test('the toggle button closes an open drawer', async () => {
    await mount()
    const { sidebar, button } = els()
    button.click() // open
    button.click() // close
    expect(sidebar.classList.contains('-translate-x-full')).toBe(true)
    expect(button.getAttribute('aria-expanded')).toBe('false')
    expect(document.body.classList.contains('overflow-hidden')).toBe(false)
  })

  test('clicking the backdrop closes the drawer', async () => {
    await mount()
    const { backdrop, sidebar, button } = els()
    button.click() // open
    backdrop.click()
    expect(sidebar.classList.contains('-translate-x-full')).toBe(true)
    expect(backdrop.classList.contains('hidden')).toBe(true)
  })

  test('pressing Escape closes the drawer', async () => {
    await mount()
    const { sidebar, button } = els()
    button.click() // open
    window.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
    expect(sidebar.classList.contains('-translate-x-full')).toBe(true)
  })
})
