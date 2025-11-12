/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import { convertDateToSystemTimeZone } from '../src/case_contact'

describe('convertDateToSystemTimeZone', () => {
  test('converts a UTC date string to a Date object', () => {
    const dateString = '2022-06-22 17:14:50 UTC'
    const result = convertDateToSystemTimeZone(dateString)

    expect(result).toBeInstanceOf(Date)
    expect(result.getTime()).toBe(new Date(dateString).getTime())
  })

  test('converts a date string without timezone to a Date object', () => {
    const dateString = '2022-06-22T12:00:00'
    const result = convertDateToSystemTimeZone(dateString)

    expect(result).toBeInstanceOf(Date)
    expect(result.getFullYear()).toBe(2022)
    expect(result.getMonth()).toBe(5) // June is month 5 (0-indexed)
    expect(result.getDate()).toBe(22)
  })

  test('creates a copy of an existing Date object', () => {
    const originalDate = new Date('2022-06-22 17:14:50 UTC')
    const result = convertDateToSystemTimeZone(originalDate)

    expect(result).toBeInstanceOf(Date)
    expect(result.getTime()).toBe(originalDate.getTime())
    expect(result).not.toBe(originalDate) // Should be a different object
  })

  test('handles ISO 8601 format', () => {
    const dateString = '2022-06-22T17:14:50.000Z'
    const result = convertDateToSystemTimeZone(dateString)

    expect(result).toBeInstanceOf(Date)
    expect(result.toISOString()).toBe(dateString)
  })

  test('returns Invalid Date for invalid date strings', () => {
    const result = convertDateToSystemTimeZone('not a valid date')

    expect(result).toBeInstanceOf(Date)
    expect(isNaN(result.getTime())).toBe(true)
  })
})
