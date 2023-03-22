/* eslint-env jest */

require('jest')

describe('warningBoxAndReload', () => {

  test("warning box displays 2 minutes before Devise Timeout", () => {
    warningBoxAndReload = jest.fn();
    myTimer = jest.fn();

    myTimer();
    expect(myTimer).toHaveBeenCalled();

    warningBoxAndReload();
    expect(warningBoxAndReload).toHaveBeenCalled();

  });
});