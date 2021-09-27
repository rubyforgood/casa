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
  test('', (done) => {
    $(document).ready(() => {
      try {
        courtOrderList.addCourtOrder()
        done()
      } catch (error) {
        done(error)
      }
    })
  })
})

describe('removeCourtOrder', () => {
})
