/* eslint-env jest, browser */
/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus'
import EmancipationChecklistController from '../controllers/emancipation_checklist_controller'

const flush = () => new Promise((resolve) => setTimeout(resolve, 0))

// Mirrors app/views/emancipations/show.html.erb. The controller element wraps the list.
// Each .category-options div is the immediate sibling after its .emancipation-category h2.
// The collapse icon sits beside, not inside, the .emacipation-category-input-label-pair.
const pageHtml = () => `
  <div data-controller="emancipation-checklist"
       data-emancipation-checklist-save-path-value="/casa_cases/case-1/emancipation/save">
    <p role="status" data-emancipation-checklist-target="status"></p>
    <p role="alert" data-emancipation-checklist-target="error"></p>

    <h2 class="emancipation-category" id="category" data-is-open="false">
      <div class="emacipation-category-input-label-pair" data-action="click->emancipation-checklist#toggleCategory">
        <input type="checkbox" class="emancipation-category-check-box" value="7">
      </div>
      <span class="category-collapse-icon" data-action="click->emancipation-checklist#toggleChildren">+</span>
    </h2>
    <div class="category-options" id="options" style="display: none;">
      <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
        <input type="checkbox" class="emancipation-option-check-box" id="O11" value="11">
        <label>With friend</label>
      </div>
    </div>

    <h2 class="emancipation-category" id="control-category" data-is-open="false">
      <div class="emacipation-category-input-label-pair" data-action="click->emancipation-checklist#toggleCategory">
        <input type="checkbox" class="emancipation-category-check-box" value="9">
      </div>
      <span class="category-collapse-icon" data-action="click->emancipation-checklist#toggleChildren">+</span>
    </h2>
    <div class="category-options" id="control-options" style="display: none;">
      <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
        <input type="checkbox" class="emancipation-option-check-box" id="O22" value="22">
        <label>On my own</label>
      </div>
    </div>
  </div>
`

describe('emancipation_checklist_controller', () => {
  let application
  let fetchMock
  const originalFetch = global.fetch

  const mount = async (html = pageHtml()) => {
    document.body.innerHTML = html
    application = Application.start()
    application.register('emancipation-checklist', EmancipationChecklistController)
    await flush()
  }

  beforeEach(() => {
    fetchMock = jest.fn()
    global.fetch = fetchMock
  })

  afterEach(() => {
    if (application) application.stop()
    document.body.innerHTML = ''
    global.fetch = originalFetch
  })

  const successResponse = () => ({ ok: true, status: 200, json: async () => 'success' })
  const errorResponse = (error) => ({ ok: false, status: 400, json: async () => ({ error }) })

  const category = () => document.querySelector('#category')
  const categoryCheckbox = () => document.querySelector('.emancipation-category-check-box')
  const categoryLabelPair = () => category().querySelector('.emacipation-category-input-label-pair')
  const collapseIcon = () => category().querySelector('.category-collapse-icon')
  const options = () => document.querySelector('#options')
  const optionItem = () => options().querySelector('.check-item')
  const optionInput = () => optionItem().querySelector('input')
  const statusEl = () => document.querySelector('[data-emancipation-checklist-target="status"]')
  const errorEl = () => document.querySelector('[data-emancipation-checklist-target="error"]')

  test('checking a category saves it, opens its options, and updates only the affected category', async () => {
    fetchMock.mockResolvedValue(successResponse())
    await mount()

    categoryLabelPair().click()
    await flush()

    expect(fetchMock).toHaveBeenCalledTimes(1)
    expect(fetchMock.mock.calls[0][0]).toBe('/casa_cases/case-1/emancipation/save')
    expect(fetchMock.mock.calls[0][1].method).toBe('POST')
    expect(fetchMock.mock.calls[0][1].body).toBe('check_item_action=add_category&check_item_id=7')

    expect(categoryCheckbox().checked).toBe(true)
    expect(category().dataset.isOpen).toBe('true')
    expect(options().style.display).toBe('')
    expect(collapseIcon().textContent).toBe('−')
    expect(statusEl().textContent).toBe('Saved')
    expect(errorEl().textContent).toBe('')

    const controlOptions = document.querySelector('#control-options')
    expect(controlOptions.style.display).toBe('none')
  })

  test('unchecking a category saves it, closes its options, and reports the cleared options', async () => {
    fetchMock.mockResolvedValue(successResponse())
    await mount(`
      <div data-controller="emancipation-checklist"
           data-emancipation-checklist-save-path-value="/casa_cases/case-1/emancipation/save">
        <p role="status" data-emancipation-checklist-target="status"></p>
        <p role="alert" data-emancipation-checklist-target="error"></p>
        <h2 class="emancipation-category" id="category" data-is-open="true">
          <div class="emacipation-category-input-label-pair" data-action="click->emancipation-checklist#toggleCategory">
            <input type="checkbox" class="emancipation-category-check-box" value="7" checked>
          </div>
          <span class="category-collapse-icon" data-action="click->emancipation-checklist#toggleChildren">−</span>
        </h2>
        <div class="category-options" id="options">
          <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
            <input type="checkbox" class="emancipation-option-check-box" id="O11" value="11" checked>
            <label>With friend</label>
          </div>
        </div>
      </div>
    `)

    categoryLabelPair().click()
    await flush()

    expect(fetchMock.mock.calls[0][1].body).toBe('check_item_action=delete_category&check_item_id=7')
    expect(categoryCheckbox().checked).toBe(false)
    expect(category().dataset.isOpen).toBe('false')
    expect(options().style.display).toBe('none')
    expect(optionInput().checked).toBe(false)
    expect(statusEl().textContent).toBe('Unchecked With friend')
    expect(collapseIcon().textContent).toBe('+')
  })

  test('checking an option saves add_option and unchecking saves delete_option', async () => {
    fetchMock.mockResolvedValue(successResponse())
    await mount()

    categoryLabelPair().click()
    await flush()
    fetchMock.mockClear()

    optionItem().click()
    await flush()

    expect(fetchMock).toHaveBeenCalledTimes(1)
    expect(fetchMock.mock.calls[0][1].body).toBe('check_item_action=add_option&check_item_id=11')
    expect(optionInput().checked).toBe(true)
    expect(statusEl().textContent).toBe('Saved')

    optionItem().click()
    await flush()

    expect(fetchMock).toHaveBeenCalledTimes(2)
    expect(fetchMock.mock.calls[1][1].body).toBe('check_item_action=delete_option&check_item_id=11')
    expect(optionInput().checked).toBe(false)
  })

  test('a server error keeps the checkbox state and shows the error', async () => {
    fetchMock.mockResolvedValue(errorResponse('The current case is not marked as transitioning'))
    await mount()

    categoryLabelPair().click()
    await flush()

    expect(categoryCheckbox().checked).toBe(false)
    expect(category().dataset.isOpen).toBe('false')
    expect(errorEl().textContent).toBe('The current case is not marked as transitioning')
    expect(statusEl().textContent).toBe('')
  })

  test('a network failure shows a readable error', async () => {
    fetchMock.mockRejectedValue(new TypeError('Failed to fetch'))
    await mount()

    optionItem().click()
    await flush()

    expect(errorEl().textContent).toBe('Unable to save the change. Check your connection and try again.')
    expect(optionInput().checked).toBe(false)
  })

  test('clicks during an in-flight save do not post twice', async () => {
    let resolveFetch
    fetchMock.mockImplementation(() => new Promise((resolve) => { resolveFetch = resolve }))
    await mount()

    categoryLabelPair().click()
    categoryLabelPair().click()

    expect(fetchMock).toHaveBeenCalledTimes(1)

    resolveFetch(successResponse())
    await flush()

    expect(categoryCheckbox().checked).toBe(true)
  })

  test('an already selected radio posts nothing', async () => {
    fetchMock.mockResolvedValue(successResponse())
    await mount(`
      <div data-controller="emancipation-checklist"
           data-emancipation-checklist-save-path-value="/casa_cases/case-1/emancipation/save">
        <p role="status" data-emancipation-checklist-target="status"></p>
        <p role="alert" data-emancipation-checklist-target="error"></p>
        <h2 class="emancipation-category" id="category" data-is-open="true">
          <div class="emacipation-category-input-label-pair" data-action="click->emancipation-checklist#toggleCategory">
            <input type="checkbox" class="emancipation-category-check-box" value="7" checked>
          </div>
        </h2>
        <div class="category-options" id="options">
          <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
            <input type="radio" class="emancipation-radio-button" name="C7" value="11" checked>
            <label>With friend</label>
          </div>
          <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
            <input type="radio" class="emancipation-radio-button" name="C7" value="22">
            <label>On my own</label>
          </div>
        </div>
      </div>
    `)

    optionItem().click()
    await flush()

    expect(fetchMock).not.toHaveBeenCalled()
  })

  test('selecting another radio posts set_option and blocks the group while in flight', async () => {
    let resolveFetch
    fetchMock.mockImplementation(() => new Promise((resolve) => { resolveFetch = resolve }))
    await mount(`
      <div data-controller="emancipation-checklist"
           data-emancipation-checklist-save-path-value="/casa_cases/case-1/emancipation/save">
        <p role="status" data-emancipation-checklist-target="status"></p>
        <p role="alert" data-emancipation-checklist-target="error"></p>
        <h2 class="emancipation-category" id="category" data-is-open="true">
          <div class="emacipation-category-input-label-pair" data-action="click->emancipation-checklist#toggleCategory">
            <input type="checkbox" class="emancipation-category-check-box" value="7" checked>
          </div>
        </h2>
        <div class="category-options" id="options">
          <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
            <input type="radio" class="emancipation-radio-button" name="C7" value="11" checked>
            <label>With friend</label>
          </div>
          <div class="check-item" data-action="click->emancipation-checklist#toggleOption">
            <input type="radio" class="emancipation-radio-button" name="C7" value="22">
            <label>On my own</label>
          </div>
        </div>
      </div>
    `)

    const items = options().querySelectorAll('.check-item')
    items[1].click()
    items[0].click()

    expect(fetchMock).toHaveBeenCalledTimes(1)
    expect(fetchMock.mock.calls[0][1].body).toBe('check_item_action=set_option&check_item_id=22')

    resolveFetch(successResponse())
    await flush()

    expect(items[1].querySelector('input').checked).toBe(true)
    expect(items[0].querySelector('input').checked).toBe(false)
    expect(statusEl().textContent).toBe('Saved')
  })

  test('the collapse icon opens and closes options without saving', async () => {
    fetchMock.mockResolvedValue(successResponse())
    await mount()

    collapseIcon().click()
    await flush()

    expect(fetchMock).not.toHaveBeenCalled()
    expect(category().dataset.isOpen).toBe('true')
    expect(options().style.display).toBe('')
    expect(collapseIcon().textContent).toBe('−')

    collapseIcon().click()
    await flush()

    expect(category().dataset.isOpen).toBe('false')
    expect(options().style.display).toBe('none')
    expect(collapseIcon().textContent).toBe('+')
  })
})
