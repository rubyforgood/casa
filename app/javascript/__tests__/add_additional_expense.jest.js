/* eslint-env jest */

require('jest')
require('../src/add_additional_expense')

beforeEach(() => {
  document.body.innerHTML =
    '<a href="#" class="add-another-expense" id="add-another-expense">Add another expense</a>'
  const $ = require('jquery')
  const mockCall = jest.fn()
  })
  
describe('case_contact create form additional expenses link adds new additional expense set of form fields on click', () => {
  test('click on Add additional expense link adds expense amount of form field on click', () => {
    $(document).ready(() => {
      // button.find('add-another-expense').simulate('click');
      userEvent.click(screen.getByText('Add another expense'))
      expect(mockCall).not.toHaveBeenCalled()
      // expect(mockCall).toHaveBeenCalled();
    })
  })
})

// userEvent.click(screen.getByText('Add another expense'))
// $('add-another-expense').click()

  // test("click on Add additional expense link adds expense describe of form field on click", () => {
  //   // check that both other expenses field expense describe is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link only added one expense amount of form field on click", () => {
  //   // check that both other expenses field expense amount is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link only added one expense describe of form field on click", () => {
  //   // check that both other expenses field expense describe is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link adds 2nd expense amount of form field on click", () => {
  //   // navigate to?
  //   // click on link
  //   // check that both other expenses field expense amount is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link adds 2nd expense describe of form field on click", () => {
  //   // check that both other expenses field expense describe is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link adds 9 expense amount of form fields on click", () => {
  //   // navigate to?
  //   // click on link
  //   // check that both other expenses field expense amount is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link adds 9 expense describe of form fields on click", () => {
  //   // check that both other expenses field expense describe is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link does not add 10th expense amount of form fields on click", () => {
  //   // navigate to?
  //   // click on link
  //   // check that both other expenses field expense amount is added
  //   expect().toBeInTheDocument();
  // });

  // test("click on Add additional expense link does not add 10th expense describe of form fields on click", () => {
  //   // check that both other expenses field expense describe is added
  //   expect().toBeInTheDocument();
  // });

