/* eslint-env jest */

require('jest')
const CourtOrderList = require('../src/court_order_list.js')

let courtOrderListElement
let courtOrderList

delete window.location
window.location = { reload: jest.fn() }

beforeEach(() => {
  // jest doesn't support window.location like a browser but URL is pretty close
  // see https://stackoverflow.com/a/60697570
  window.location = new URL('https://casa-qa.herokuapp.com/casa_cases/CINA-2151')
  document.body.innerHTML = '<div id="court-orders-list-container" data-resource="casa_case"></div>'

  $(document).ready(() => {
    courtOrderListElement = $('#court-orders-list-container')
    courtOrderList = new CourtOrderList(courtOrderListElement)
  })
})

describe('CourtOrderList constructor', () => {
  test('the constructor should be able to extract the resource name from element', (done) => {
    $(document).ready(() => {
      try {
        courtOrderList = new CourtOrderList(courtOrderListElement)

        expect(courtOrderList.resourceName).toBe('casa_case')
        done()
      } catch (error) {
        done(error)
      }
    })
  })

  test('the constructor should be able to extract the casa case id from the url', (done) => {
    $(document).ready(() => {
      try {
        const casaCaseId1 = 'CINA-2151'
        const casaCaseId2 = 'CINA-1988'
        window.location = new URL(`https://casa-qa.herokuapp.com/casa_cases/${casaCaseId1}`)
        courtOrderList = new CourtOrderList(courtOrderListElement)

        expect(courtOrderList.casaCaseId).toBe(casaCaseId1)

        window.location = new URL(`https://casa-qa.herokuapp.com/casa_cases/${casaCaseId2}/court_dates/3`)
        courtOrderList = new CourtOrderList(courtOrderListElement)

        expect(courtOrderList.casaCaseId).toBe(casaCaseId2)
        done()
      } catch (error) {
        done(error)
      }
    })
  })
})

describe('addCourtOrder', () => {
  test('addCourtOrder should add a textarea and dropdown in a div with class "court-order-entry" as a child of #court-orders-list-container', (done) => {
    $(document).ready(() => {
      try {
        expect(courtOrderListElement.children().length).toBe(0)

        courtOrderList.addCourtOrder()

        expect(courtOrderListElement.children().length).toBe(1)

        const appendedCourtOrder = courtOrderListElement.children().first()
        expect(appendedCourtOrder.attr('class')).toContain('court-order-entry')
        expect(appendedCourtOrder.find('textarea').length).toBe(1)
        expect(appendedCourtOrder.find('select').length).toBe(1)
        expect(appendedCourtOrder.find('input[type="hidden"]').length).toBe(1)
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
          expect($(textArea).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_text`)
          expect($(textArea).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][text]`)

          const select = courtOrderInputs.find('select')
          expect($(select).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_implementation_status`)
          expect($(select).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][implementation_status]`)

          const hiddenInput = courtOrderInputs.find('input[type="hidden"]')
          expect($(hiddenInput).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_casa_case_id`)
          expect($(hiddenInput).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][casa_case_id]`)
        })

        courtOrderListElement.children('input').each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_id`)
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
        <div class="court-order-entry">\
          <textarea name="casa_case[case_court_orders_attributes][0][text]" id="casa_case_case_court_orders_attributes_0_text">${courtOrdersText[0]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_orders_attributes][0][implementation_status]" id="casa_case_case_court_orders_attributes_0_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="unimplemented">Not implemented</option>
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>
          </select>\
          <button type="button" class="remove-court-order-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="202" name="casa_case[case_court_orders_attributes][0][id]" id="casa_case_case_court_orders_attributes_0_id">\
        <div class="court-order-entry">\
          <textarea name="casa_case[case_court_orders_attributes][1][text]" id="casa_case_case_court_orders_attributes_1_text">${courtOrdersText[1]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_orders_attributes][1][implementation_status]" id="casa_case_case_court_orders_attributes_1_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="unimplemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option></select>\
          <button type="button" class="remove-court-order-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="203" name="casa_case[case_court_orders_attributes][1][id]" id="casa_case_case_court_orders_attributes_1_id">\
        <div class="court-order-entry">\
          <textarea name="casa_case[case_court_orders_attributes][2][text]" id="casa_case_case_court_orders_attributes_2_text">${courtOrdersText[2]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_orders_attributes][2][implementation_status]" id="casa_case_case_court_orders_attributes_2_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="unimplemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>\
          </select>\
          <button type="button" class="remove-court-order-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="204" name="casa_case[case_court_orders_attributes][2][id]" id="casa_case_case_court_orders_attributes_2_id">\
        <div class="court-order-entry">\
          <textarea name="casa_case[case_court_orders_attributes][3][text]" id="casa_case_case_court_orders_attributes_3_text">${courtOrdersText[3]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_orders_attributes][3][implementation_status]" id="casa_case_case_court_orders_attributes_3_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="unimplemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>\
          </select>\
          <button type="button" class="remove-court-order-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="205" name="casa_case[case_court_orders_attributes][3][id]" id="casa_case_case_court_orders_attributes_3_id">\
        <div class="court-order-entry">\
          <textarea name="casa_case[case_court_orders_attributes][4][text]" id="casa_case_case_court_orders_attributes_4_text">${courtOrdersText[4]}</textarea>\
          <select class="implementation-status" name="casa_case[case_court_orders_attributes][4][implementation_status]" id="casa_case_case_court_orders_attributes_4_implementation_status">\
            <option value="">Set Implementation Status</option>\
            <option value="unimplemented">Not implemented</option>\
            <option value="partially_implemented">Partially implemented</option>\
            <option value="implemented">Implemented</option>\
          </select>\
          <button type="button" class="remove-order-order-button btn btn-danger">Delete</button>\
        </div>\
        <input type="hidden" value="206" name="casa_case[case_court_orders_attributes][4][id]" id="casa_case_case_court_orders_attributes_4_id">\
      `))
    })
  })

  test('removeCourtOrder should remove the elements passed to it', (done) => {
    $(document).ready(() => {
      try {
        expect(courtOrderListElement.children().length).toBe(10)
        expect($('#casa_case_case_court_orders_attributes_4_text').length).toBe(1)
        expect($('#casa_case_case_court_orders_attributes_4_implementation_status').length).toBe(1)
        expect($('#casa_case_case_court_orders_attributes_4_id').length).toBe(1)
        expect(document.body.innerHTML).toEqual(expect.stringContaining(courtOrdersText[4]))

        courtOrderList.removeCourtOrder($('.court-order-entry').eq(4), $('#casa_case_case_court_orders_attributes_4_id'))

        expect(courtOrderListElement.children().length).toBe(8)
        expect($('#casa_case_case_court_orders_attributes_4_text').length).toBe(0)
        expect($('#casa_case_case_court_orders_attributes_4_implementation_status').length).toBe(0)
        expect($('#casa_case_case_court_orders_attributes_4_id').length).toBe(0)
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
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_id`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][id]`)
        })

        expect(textareas.length).toBe(5)
        textareas.each(function (index) {
          expect($(this).html()).toBe(courtOrdersText[index])
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_text`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][text]`)
        })

        expect(selects.length).toBe(5)
        selects.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_implementation_status`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][implementation_status]`)
        })

        courtOrderList.removeCourtOrder($('.court-order-entry').eq(0), $('#casa_case_case_court_orders_attributes_0_id'))

        expect(document.body.innerHTML).toEqual(expect.not.stringContaining(courtOrdersText[0]))

        inputs = courtOrderListElement.children('input')
        textareas = courtOrderListElement.find('textarea')
        selects = courtOrderListElement.find('select')

        expect(inputs.length).toBe(4)
        inputs.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_id`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][id]`)
        })

        expect(textareas.length).toBe(4)
        textareas.each(function (index) {
          expect($(this).html()).toBe(courtOrdersText[index + 1])
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_text`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][text]`)
        })

        expect(selects.length).toBe(4)
        selects.each(function (index) {
          expect($(this).attr('id')).toBe(`casa_case_case_court_orders_attributes_${index}_implementation_status`)
          expect($(this).attr('name')).toBe(`casa_case[case_court_orders_attributes][${index}][implementation_status]`)
        })
        done()
      } catch (error) {
        done(error)
      }
    })
  })
})
