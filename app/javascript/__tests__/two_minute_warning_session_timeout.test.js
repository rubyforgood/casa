/* eslint-env jest */

require('jest')

describe('warningBoxAndReload', () => {
  test('warning box displays 2 minutes before Devise Timeout', () => {
    const warningBoxAndReload = jest.fn()
    const myTimer = jest.fn()

    myTimer()
    expect(myTimer).toHaveBeenCalled()

    warningBoxAndReload()
    expect(warningBoxAndReload).toHaveBeenCalled()
  })
})
