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
  const courtOrdersText = ['Ycs(ya$5r^/9QIQG', ')Tf/_T0a%h1q\'N:[', '\\VvOfNZ(xZ~:1Hj?', '"(N=D,s4Q"QcH?F+', '!N0&amp;!J31#LX+d$,k']

  beforeEach(() => {
    $(document).ready(() => {
      courtOrderListElement.append($(`\
        <div class="court-mandate-entry">\
          <textarea name="casa_case[case_court_mandates_attributes][0][mandate_text]" id="casa_case_case_court_mandates_attributes_0_mandate_text">${courtOrdersText[0]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_mandates_attributes][0][implementation_status]" id="casa_case_case_court_mandates_attributes_0_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="not_implemented">Not implemented</option>
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>
          </select>\
          <button type="button" class="remove-mandate-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="202" name="casa_case[case_court_mandates_attributes][0][id]" id="casa_case_case_court_mandates_attributes_0_id">\
        <div class="court-mandate-entry">\
          <textarea name="casa_case[case_court_mandates_attributes][1][mandate_text]" id="casa_case_case_court_mandates_attributes_1_mandate_text">${courtOrdersText[1]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_mandates_attributes][1][implementation_status]" id="casa_case_case_court_mandates_attributes_1_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="not_implemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option></select>\
          <button type="button" class="remove-mandate-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="203" name="casa_case[case_court_mandates_attributes][1][id]" id="casa_case_case_court_mandates_attributes_1_id">\
        <div class="court-mandate-entry">\
          <textarea name="casa_case[case_court_mandates_attributes][2][mandate_text]" id="casa_case_case_court_mandates_attributes_2_mandate_text">${courtOrdersText[2]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_mandates_attributes][2][implementation_status]" id="casa_case_case_court_mandates_attributes_2_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="not_implemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>\
          </select>\
          <button type="button" class="remove-mandate-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="204" name="casa_case[case_court_mandates_attributes][2][id]" id="casa_case_case_court_mandates_attributes_2_id">\
        <div class="court-mandate-entry">\
          <textarea name="casa_case[case_court_mandates_attributes][3][mandate_text]" id="casa_case_case_court_mandates_attributes_3_mandate_text">${courtOrdersText[3]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_mandates_attributes][3][implementation_status]" id="casa_case_case_court_mandates_attributes_3_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="not_implemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>\
          </select>\
          <button type="button" class="remove-mandate-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="205" name="casa_case[case_court_mandates_attributes][3][id]" id="casa_case_case_court_mandates_attributes_3_id">\
        <div class="court-mandate-entry">\
          <textarea name="casa_case[case_court_mandates_attributes][4][mandate_text]" id="casa_case_case_court_mandates_attributes_4_mandate_text">${courtOrdersText[4]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_mandates_attributes][4][implementation_status]" id="casa_case_case_court_mandates_attributes_4_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="not_implemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>\
          </select>\
          <button type="button" class="remove-mandate-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="206" name="casa_case[case_court_mandates_attributes][4][id]" id="casa_case_case_court_mandates_attributes_4_id">\
      `))
    })
  })

  test('removeCourtOrder should remove the elements passed to it', (done) => {
    $(document).ready(() => {
      try {
        expect(courtOrderListElement.children().length).toBe(10)
        expect($('#casa_case_case_court_mandates_attributes_4_mandate_text').length).toBe(1)
        expect($('#casa_case_case_court_mandates_attributes_4_implementation_status').length).toBe(1)
        expect($('#casa_case_case_court_mandates_attributes_4_id').length).toBe(1)
        expect(document.body.innerHTML).toEqual(expect.stringContaining(courtOrdersText[4]))

        courtOrderList.removeCourtOrder($('.court-mandate-entry').eq(4), $('#casa_case_case_court_mandates_attributes_4_id'))

        expect(courtOrderListElement.children().length).toBe(8)
        expect($('#casa_case_case_court_mandates_attributes_4_mandate_text').length).toBe(0)
        expect($('#casa_case_case_court_mandates_attributes_4_implementation_status').length).toBe(0)
        expect($('#casa_case_case_court_mandates_attributes_4_id').length).toBe(0)
        expect(document.body.innerHTML).toEqual(expect.not.stringContaining(courtOrdersText[4]))
        done()
      } catch (error) {
        done(error)
      }
    })
  })

  test('removeCourtOrder should shift the indicies of all the elements after the elements it removes', (done) => {
    $(document).ready(() => {
      try {
        let inputs = courtOrderListElement.children('input')
        let textareas = courtOrderListElement.find('textarea')
        let selects = courtOrderListElement.find('select')

        expect(inputs.length).toBe(5)
        inputs.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_id`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][id]`)
        })

        expect(textareas.length).toBe(5)
        textareas.each(function (index) {
          expect($(this).html()).toBe(courtOrdersText[index])
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_mandate_text`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][mandate_text]`)
        })

        expect(selects.length).toBe(5)
        selects.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_implementation_status`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][implementation_status]`)
        })

        courtOrderList.removeCourtOrder($('.court-mandate-entry').eq(0), $('#casa_case_case_court_mandates_attributes_0_id'))

        expect(document.body.innerHTML).toEqual(expect.not.stringContaining(courtOrdersText[0]))

        inputs = courtOrderListElement.children('input')
        textareas = courtOrderListElement.find('textarea')
        selects = courtOrderListElement.find('select')

        expect(inputs.length).toBe(4)
        inputs.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_id`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][id]`)
        })

        expect(textareas.length).toBe(4)
        textareas.each(function (index) {
          expect($(this).html()).toBe(courtOrdersText[index + 1])
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_mandate_text`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][mandate_text]`)
        })

        expect(selects.length).toBe(4)
        selects.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_mandates_attributes_${index}_implementation_status`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_mandates_attributes][${index}][implementation_status]`)
        })
        done()
      } catch (error) {
        done(error)
      }
    })
  })
})
