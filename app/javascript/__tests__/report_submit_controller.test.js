/* eslint-env jest, browser */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import ReportSubmitController from '../controllers/report_submit_controller'

describe('report_submit_controller', () => {
  let application

  const mount = async (html) => {
    document.body.innerHTML = html
    application = Application.start()
    application.register('report-submit', ReportSubmitController)
    await new Promise((resolve) => setTimeout(resolve, 0))
  }

  afterEach(() => {
    jest.useRealTimers()
    if (application) application.stop()
    document.body.innerHTML = ''
    jest.restoreAllMocks()
  })

  test('on click, disables the button, swaps text to data-disable-with, and calls form.submit()', async () => {
    await mount(`
      <form action="/reports/mileage" method="get">
        <button type="submit"
                data-controller="report-submit"
                data-action="click->report-submit#submit"
                data-disable-with="Downloading mileage report">
          <span>Mileage report</span>
        </button>
      </form>
    `)

    jest.useFakeTimers()

    const form = document.querySelector('form')
    const button = document.querySelector('button')
    form.submit = jest.fn()

    button.click()

    expect(button.disabled).toBe(true)
    expect(button.innerHTML).toBe('Downloading mileage report')
    expect(form.submit).toHaveBeenCalledTimes(1)
  })

  test('re-enables the button and restores original HTML after 3000ms', async () => {
    const originalHtml = '<span>Download report</span> <i class="bi bi-download"></i>'
    await mount(`
      <form action="/reports" method="get">
        <button type="submit"
                data-controller="report-submit"
                data-action="click->report-submit#submit"
                data-disable-with="Downloading report">${originalHtml}</button>
      </form>
    `)

    jest.useFakeTimers()

    const form = document.querySelector('form')
    const button = document.querySelector('button')
    form.submit = jest.fn()

    button.click()

    expect(button.disabled).toBe(true)
    expect(button.innerHTML).toBe('Downloading report')

    // Advance 2999ms: still disabled
    jest.advanceTimersByTime(2999)
    expect(button.disabled).toBe(true)
    expect(button.innerHTML).toBe('Downloading report')

    // Advance remaining 1ms (total 3000ms): re-enabled and restored
    jest.advanceTimersByTime(1)
    expect(button.disabled).toBe(false)
    expect(button.innerHTML).toBe(originalHtml)
  })

  test('prevents duplicate submissions while disabled', async () => {
    await mount(`
      <form action="/reports/missing_data" method="get">
        <button type="submit"
                data-controller="report-submit"
                data-action="click->report-submit#submit"
                data-disable-with="Downloading missing data report">Missing data report</button>
      </form>
    `)

    jest.useFakeTimers()

    const form = document.querySelector('form')
    const button = document.querySelector('button')
    form.submit = jest.fn()

    button.click()
    expect(form.submit).toHaveBeenCalledTimes(1)

    // Programmatic second click while disabled
    button.click()
    expect(form.submit).toHaveBeenCalledTimes(1)
  })

  test('handles missing form element safely without throwing errors', async () => {
    await mount(`
      <div>
        <button type="submit"
                data-controller="report-submit"
                data-action="click->report-submit#submit"
                data-disable-with="Downloading report">Orphan button</button>
      </div>
    `)

    const button = document.querySelector('button')
    expect(() => button.click()).not.toThrow()
    expect(button.disabled).toBe(false)
  })

  test('clears pending timeout when disconnected', async () => {
    await mount(`
      <form action="/reports/followup" method="get">
        <button type="submit"
                data-controller="report-submit"
                data-action="click->report-submit#submit"
                data-disable-with="Downloading followup report">Followups</button>
      </form>
    `)

    jest.useFakeTimers()

    const form = document.querySelector('form')
    const button = document.querySelector('button')
    form.submit = jest.fn()

    button.click()
    expect(button.disabled).toBe(true)

    // Disconnect controller
    application.stop()

    // Advance timers past 3000ms
    jest.advanceTimersByTime(3000)
  })

  test('respects custom timeout value if configured', async () => {
    await mount(`
      <form action="/reports/learning_hours" method="get">
        <button type="submit"
                data-controller="report-submit"
                data-action="click->report-submit#submit"
                data-report-submit-timeout-value="1500"
                data-disable-with="Downloading learning hours report">Learning hours</button>
      </form>
    `)

    jest.useFakeTimers()

    const form = document.querySelector('form')
    const button = document.querySelector('button')
    form.submit = jest.fn()

    button.click()
    expect(button.disabled).toBe(true)

    jest.advanceTimersByTime(1500)
    expect(button.disabled).toBe(false)
    expect(button.innerHTML).toBe('Learning hours')
  })
})
