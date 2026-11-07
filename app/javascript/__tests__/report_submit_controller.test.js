/* eslint-env jest, browser */
import { Application } from '@hotwired/stimulus'
import ReportSubmitController from '../controllers/report_submit_controller'

describe('report_submit_controller', () => {
  let application
  let form
  let button
  let originalHTML

  const formHTML = `
    <form action="/case_contact_reports.csv" method="get">
      <input name="report[start_date]" value="2026-11-01">
      <button type="submit" data-controller="report-submit"
        data-action="click->report-submit#submit" data-disable-with="Downloading report">
        <i class="bi bi-download" aria-hidden="true"></i> Download report
      </button>
    </form>`

  const settle = () => new Promise((resolve) => setTimeout(resolve, 0))

  beforeEach(async () => {
    document.body.innerHTML = formHTML
    application = Application.start()
    application.register('report-submit', ReportSubmitController)
    await settle()

    form = document.querySelector('form')
    form.submit = jest.fn()
    button = form.querySelector('button')
    originalHTML = button.innerHTML
    jest.useFakeTimers()
  })

  afterEach(async () => {
    jest.useRealTimers()
    document.body.innerHTML = ''
    await settle()
    application.stop()
    jest.restoreAllMocks()
  })

  test('prevents the default submit, disables the button, and submits the form natively once', () => {
    const event = new MouseEvent('click', { bubbles: true, cancelable: true })
    button.dispatchEvent(event)

    expect(event.defaultPrevented).toBe(true)
    expect(button.disabled).toBe(true)
    expect(button.textContent).toBe('Downloading report')
    expect(form.submit).toHaveBeenCalledTimes(1)
    expect(form.querySelector('input').value).toBe('2026-11-01')
  })

  test('restores the original markup and allows another export after three seconds', () => {
    button.click()
    button.click()
    expect(form.submit).toHaveBeenCalledTimes(1)

    jest.advanceTimersByTime(2999)
    expect(button.disabled).toBe(true)
    expect(button.textContent).toBe('Downloading report')

    jest.advanceTimersByTime(1)
    expect(button.disabled).toBe(false)
    expect(button.innerHTML).toBe(originalHTML)

    button.click()
    expect(form.submit).toHaveBeenCalledTimes(2)
    jest.advanceTimersByTime(3000)
    expect(button.innerHTML).toBe(originalHTML)
  })

  test('handles a click on an icon inside the button', () => {
    button.querySelector('i').dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }))

    expect(button.disabled).toBe(true)
    expect(button.textContent).toBe('Downloading report')
    expect(form.submit).toHaveBeenCalledTimes(1)
  })

  test('connects buttons added after the initial page load and keeps their timers independent', async () => {
    jest.useRealTimers()
    document.body.insertAdjacentHTML('beforeend', formHTML)
    await settle()
    const secondForm = document.querySelectorAll('form')[1]
    secondForm.submit = jest.fn()
    const secondButton = secondForm.querySelector('button')
    secondButton.dataset.disableWith = 'Downloading mileage report'
    jest.useFakeTimers()

    button.click()
    expect(secondButton.disabled).toBe(false)
    jest.advanceTimersByTime(1000)
    secondButton.click()
    expect(secondButton.textContent).toBe('Downloading mileage report')

    jest.advanceTimersByTime(2000)
    expect(button.disabled).toBe(false)
    expect(secondButton.disabled).toBe(true)
    jest.advanceTimersByTime(1000)
    expect(secondButton.disabled).toBe(false)
    expect(form.submit).toHaveBeenCalledTimes(1)
    expect(secondForm.submit).toHaveBeenCalledTimes(1)
  })

  test('cancels a pending reset on disconnect and restores the button for reconnection', async () => {
    button.click()
    form.remove()
    // Stimulus observes removals asynchronously, independently of the timer.
    await Promise.resolve()
    await Promise.resolve()

    expect(jest.getTimerCount()).toBe(0)
    expect(button.disabled).toBe(false)
    expect(button.innerHTML).toBe(originalHTML)

    jest.useRealTimers()
    document.body.appendChild(form)
    await settle()
    jest.useFakeTimers()
    button.click()
    expect(form.submit).toHaveBeenCalledTimes(2)
    jest.advanceTimersByTime(3000)
    expect(button.disabled).toBe(false)
  })
})
