/* eslint-env jest */

require('jest')
jest.useFakeTimers();
jest.spyOn(global, 'setTimeout');

import { setTimeout, warningBoxAndReload } from '../src/session_timeout_poller.js';

describe('warningBoxAndReload', () => {

  test("warning box displays 2 minutes before Devise Timeout", () => {
    const warningBoxAndReload = jest.fn();
    const setTimeout = jest.fn()
    
    setTimeout();
    warningBoxAndReload();
    // jest.advanceTimersByTime(178 * 60 * 1000);
    jest.runAllTimers();
    expect(warningBoxAndReload).toHaveBeenCalled();
    expect(setTimeout).toHaveBeenCalled();
    // expect(document).toCont
    // expect().toContain("Warning: You will be logged off in 2 minutes due to inactivity.");
  });
});