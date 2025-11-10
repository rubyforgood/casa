/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import { convertDateToSystemTimeZone } from '../src/case_contact'

test('utc date is correctly converted to system date', () => {
  expect(convertDateToSystemTimeZone('2022-06-22 17:14:50 UTC')).toEqual(new Date('2022-06-22 17:14:50 UTC'))
})
