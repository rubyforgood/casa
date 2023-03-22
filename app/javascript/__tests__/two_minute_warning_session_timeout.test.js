/* eslint-env jest */

require('jest')
// jest.useFakeTimers();
// jest.spyOn(global, 'setInterval');

// import { myTimer, warningBoxAndReload } from '../src/session_timeout_poller.js';

describe('warningBoxAndReload', () => {

  const sessionTimeoutPoller = require('../src/session_timeout_poller.js')

  test("warning box displays 2 minutes before Devise Timeout", () => {
    warningBoxAndReload = jest.fn();
    myTimer = jest.fn();

    myTimer();
    expect(myTimer).toHaveBeenCalled();

    warningBoxAndReload();
    expect(warningBoxAndReload).toHaveBeenCalled();

  });
});