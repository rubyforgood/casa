/* eslint-env jest */

require('jest')
const CourtOrderList = require('../src/court_order_list.js')

let courtOrderListElement
let courtOrderList

beforeEach(() => {
  document.body.innerHTML = '<div id="court-orders-list-container"></div>'

  $(document).ready(() => {
    courtOrderListElement = $('#court-orders-list-container')
    courtOrderList = new CourtOrderList(courtOrderListElement)
  })
})

describe('addCourtOrder', () => {
  test('addCourtOrder should add a textarea and dropdown in a div with class "court-mandate-entry" as a child of #court-orders-list-container', (done) => {
    $(document).ready(() => {
      try {
        expect(courtOrderListElement.children().length).toBe(0)

        courtOrderList.addCourtOrder()

        expect(courtOrderListElement.children().length).toBe(1)

        const appendedCourtOrder = courtOrderListElement.children().first()
        expect(appendedCourtOrder.attr('class')).toContain('court-mandate-entry')
        expect(appendedCourtOrder.find('textarea').length).toBe(1)
        expect(appendedCourtOrder.find('select').length).toBe(1)
        done()
      } catch (error) {
        done(error)
      }
    })
  })

  test('addCourtOrder should add elements with attribute values containing the correct indices', (done) => {
    $(document).ready(() => {
      try {
        const courtOrderCount = 5

        for (let i = 0; i < courtOrderCount; i++) {
          courtOrderList.addCourtOrder()
        }

        courtOrderListElement.children('div').each(function (index) {
          const courtOrderInputs = $(this)

          const textArea = courtOrderInputs.find('textarea')
          expect($(textArea).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_mandate_text`)
          expect($(textArea).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][mandate_text]`)

          const select = courtOrderInputs.find('select')
          expect($(select).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_implementation_status`)
          expect($(select).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][implementation_status]`)
        })

        courtOrderListElement.children('input').each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_id`)
        })

        done()
      } catch (error) {
        done(error)
      }
    })
  })
})

describe('removeCourtOrder', () => {
})
