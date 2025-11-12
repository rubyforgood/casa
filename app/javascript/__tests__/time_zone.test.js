/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import { findTimeZone } from '../src/time_zone'

describe('findTimeZone', () => {
  test('returns a string timezone name', () => {
    const timezone = findTimeZone()

    expect(typeof timezone).toBe('string')
    expect(timezone.length).toBeGreaterThan(0)
  })

  test('returns a valid timezone string format', () => {
    const timezone = findTimeZone()

    // Timezone should be in format like "America/New_York" or "Europe/London"
    // Common formats: Continent/City or UTC
    expect(timezone).toMatch(/^[A-Za-z_]+\/[A-Za-z_]+$|^UTC$|^[A-Z]{3,4}$/)
  })

  test('returns consistent result when called multiple times', () => {
    const timezone1 = findTimeZone()
    const timezone2 = findTimeZone()

    expect(timezone1).toBe(timezone2)
  })

  test('handles environments where Intl is available', () => {
    // This test just verifies the function doesn't throw when Intl exists
    expect(() => {
      findTimeZone()
    }).not.toThrow()
  })
})
