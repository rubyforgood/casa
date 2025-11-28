/* eslint-env jest, browser */
/**
 * @jest-environment jsdom
 */

describe('read_more', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div class="js-read-more-text-wrapper">
        <div class="js-truncated-text" style="display: block;">
          Short text...
        </div>
        <div class="js-full-text" style="display: none;">
          This is the full text that is initially hidden.
        </div>
        <button class="js-read-more">Read More</button>
        <button class="js-read-less" style="display: none;">Read Less</button>
      </div>
    `

    // Require the module after setting up the DOM
    jest.isolateModules(() => {
      require('../src/read_more')
    })

    // Trigger DOMContentLoaded
    const event = new Event('DOMContentLoaded')
    document.dispatchEvent(event)
  })

  test('shows full text and hides truncated text when Read More is clicked', () => {
    const readMoreButton = document.querySelector('.js-read-more')
    const truncatedText = document.querySelector('.js-truncated-text')
    const fullText = document.querySelector('.js-full-text')

    expect(truncatedText.style.display).toBe('block')
    expect(fullText.style.display).toBe('none')

    readMoreButton.click()

    expect(truncatedText.style.display).toBe('none')
    expect(fullText.style.display).toBe('block')
  })

  test('shows truncated text and hides full text when Read Less is clicked', () => {
    const readMoreButton = document.querySelector('.js-read-more')
    const readLessButton = document.querySelector('.js-read-less')
    const truncatedText = document.querySelector('.js-truncated-text')
    const fullText = document.querySelector('.js-full-text')

    // First expand
    readMoreButton.click()
    expect(fullText.style.display).toBe('block')

    // Then collapse
    readLessButton.click()
    expect(truncatedText.style.display).toBe('block')
    expect(fullText.style.display).toBe('none')
  })

  test('prevents default event behavior on Read More click', () => {
    const readMoreButton = document.querySelector('.js-read-more')
    const event = new MouseEvent('click', { bubbles: true, cancelable: true })
    const preventDefaultSpy = jest.spyOn(event, 'preventDefault')

    readMoreButton.dispatchEvent(event)

    expect(preventDefaultSpy).toHaveBeenCalled()
  })

  test('prevents default event behavior on Read Less click', () => {
    const readLessButton = document.querySelector('.js-read-less')
    const event = new MouseEvent('click', { bubbles: true, cancelable: true })
    const preventDefaultSpy = jest.spyOn(event, 'preventDefault')

    readLessButton.dispatchEvent(event)

    expect(preventDefaultSpy).toHaveBeenCalled()
  })

  test('handles multiple read more/less wrappers independently', () => {
    document.body.innerHTML = `
      <div class="js-read-more-text-wrapper" id="wrapper1">
        <div class="js-truncated-text" style="display: block;">Short 1</div>
        <div class="js-full-text" style="display: none;">Full 1</div>
        <button class="js-read-more">Read More</button>
      </div>
      <div class="js-read-more-text-wrapper" id="wrapper2">
        <div class="js-truncated-text" style="display: block;">Short 2</div>
        <div class="js-full-text" style="display: none;">Full 2</div>
        <button class="js-read-more">Read More</button>
      </div>
    `

    jest.isolateModules(() => {
      require('../src/read_more')
    })
    document.dispatchEvent(new Event('DOMContentLoaded'))

    const wrapper1ReadMore = document.querySelector('#wrapper1 .js-read-more')
    const wrapper1Full = document.querySelector('#wrapper1 .js-full-text')
    const wrapper2Full = document.querySelector('#wrapper2 .js-full-text')

    wrapper1ReadMore.click()

    // Only wrapper1 should be expanded
    expect(wrapper1Full.style.display).toBe('block')
    expect(wrapper2Full.style.display).toBe('none')
  })
})
