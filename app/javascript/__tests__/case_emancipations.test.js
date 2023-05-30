/* eslint-env jest */
import { Toggler } from '../src/case_emancipation'

require('jest')

let category
let categoryOptions
let categoryOptionsControl
let categoryCollapseIcon
let checkBox
let toggler

beforeEach(() => {
  document.body.innerHTML = `
  <div class="card card-container">
    <div class="card-body">
        <div>
          <h6 class="emancipation-category no-select" id="category-under-test" data-is-open='false'>
            <input type="checkbox" class="emancipation-category-check-box" value="1">
            <label>Youth has housing.</label>
              <span class="category-collapse-icon" id="icon-under-test">+</span>
          </h6>
          <div
            class="category-options"
            id="category-options-under-test"
            style="display: none;">
              <div class="check-item">
                <input type="checkbox" id="O1" class="emancipation-option-check-box" value="1" checked>
                <label>With Friend</label>
              </div>
          </div>
          <h6 class="emancipation-category no-select" id="category-control" data-is-open='false'>
            <input type="checkbox" class="emancipation-category-check-box" value="1">
            <label>Youth has housing.</label>
              <span class="category-collapse-icon">+</span>
          </h6>
          <div
            class="category-options"
            id="category-options-control"
            style="display: none;">
              <div class="check-item">
                <input type="checkbox" id="O2" class="emancipation-option-check-box" value="1" checked>
                <label>With Friend</label>
              </div>
          </div>
        </div>
    </div>
  </div>
  `

  category = $('#category-under-test')
  categoryOptions = $('#category-options-under-test')
  categoryOptionsControl = $('#category-options-control')
  categoryCollapseIcon = $('#icon-under-test')
  checkBox = $('#O1')
  toggler = new Toggler(category)
})

describe('Function that changes the text of the Toggler based on the state of the parent', () => {
  test('Changes the toggler text to -', () => {
    category.attr('data-is-open', 'false')

    toggler.manageTogglerText()
    expect(categoryCollapseIcon.text()).toEqual('+')
  })
})

describe('Function that opens the children of a given parent', () => {
  test('Opens the categoryOptionsContainer', () => {
    toggler.openChildren()
    expect(category.data('is-open')).toEqual(true)
    expect(categoryOptions.css('display')).toEqual('block')
    expect(categoryOptionsControl.css('display')).toEqual('none')
  })
})

describe('Function that closes the children of a given parent', () => {
  test('Closes the categoryOptionsContainer', () => {
    toggler.closeChildren()
    expect(category.data('is-open')).toEqual(false)
  })
})

describe('Function that deselects the children of a deselected parent', () => {
  test('Deselects the inputs in the categoryOptionsContainer', () => {
    toggler.deselectChildren(() => '')
    expect(checkBox.prop('checked')).toEqual(false)
  })
})
