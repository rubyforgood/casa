/* eslint-env jest */
import { convertDateToSystemTimeZone } from '../src/case_contact'

require('jest')

test('utc date is correctly converted to system date', () => {
  expect(convertDateToSystemTimeZone('2022-06-22 17:14:50 UTC')).toEqual(new Date('2022-06-22 17:14:50 UTC'))
})
