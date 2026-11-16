/**
 * @jest-environment node
 */
/* eslint-env jest */

describe('session_timeout_poller', () => {
  let mockAlert
  let mockReload

  beforeEach(() => {
    jest.useFakeTimers()
    jest.setSystemTime(new Date('2026-01-01T00:00:00Z'))

    mockAlert = jest.fn()
    mockReload = jest.fn()

    global.window = {
      timeout: 3,
      alert: mockAlert,
      location: {
        reload: mockReload
      }
    }
  })

  afterEach(() => {
    jest.clearAllTimers()
    delete global.window
    jest.useRealTimers()
    jest.resetModules()
  })

  test('timer runs every second', () => {
    const setIntervalSpy = jest.spyOn(global, 'setInterval')

    require('../src/session_timeout_poller')

    expect(setIntervalSpy).toHaveBeenCalledWith(expect.any(Function), 1000)

    setIntervalSpy.mockRestore()
  })

  test('shows the two-minute warning after the warning threshold', () => {
    let timerCallback
    const setIntervalSpy = jest
      .spyOn(global, 'setInterval')
      .mockImplementation(callback => {
        timerCallback = callback
      })

    require('../src/session_timeout_poller')
    setIntervalSpy.mockRestore()

    expect(timerCallback).toEqual(expect.any(Function))

    // With a 3-minute timeout, the warning threshold is after 1 minute.
    jest.setSystemTime(new Date('2026-01-01T00:01:01Z'))
    timerCallback()
    timerCallback()

    expect(mockAlert).toHaveBeenCalledWith(
      'Warning: You will be logged off in 2 minutes due to inactivity.'
    )
    expect(mockReload).toHaveBeenCalledTimes(1)
  })

  test('reloads when the session timeout has elapsed', () => {
    let timerCallback
    const setIntervalSpy = jest
      .spyOn(global, 'setInterval')
      .mockImplementation(callback => {
        timerCallback = callback
      })

    require('../src/session_timeout_poller')
    setIntervalSpy.mockRestore()

    expect(timerCallback).toEqual(expect.any(Function))

    // Simulate returning after the full 3-minute timeout has elapsed.
    jest.setSystemTime(new Date('2026-01-01T00:03:01Z'))
    timerCallback()
    timerCallback()

    expect(mockAlert).not.toHaveBeenCalled()
    expect(mockReload).toHaveBeenCalledTimes(1)
  })
})
