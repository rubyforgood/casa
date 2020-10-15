/* eslint-env jest */
'use strict'

require('jest')
var $ = require('jquery')
var _ = require('lodash')
global.$ = $
global.jQuery = $

describe('dashboard.js', () => {
  describe('DataTable tests', () => {
    function initializeDocumentWithTable (id, numberOfRows = 1) {
      var mockTable = `<table id=${id}>` +
                      '<tr> <th>Column1</th> <th>Column2</th> <th>Column3</th> </tr>'
      _.range(numberOfRows).forEach((rowNum) => (
        mockTable += '<tr> ' +
                      `  <td>some data#${rowNum}</td>` +
                      `  <td>other data#${rowNum}</td>` +
                      `  <td>more data#${rowNum}</td> ` +
                      '</tr>'
      ))
      mockTable += '</table>'
      document.body.innerHTML = mockTable
      // trying to get the sideffects to trigger
      require('../src/dashboard')
    }

    describe('casa_cases table', () => {
      test("displays 'No active cases' if the table is empty", () => {
        window.onload = (event) => {
        }
        initializeDocumentWithTable('casa_cases', 0)

        expect($.contains($('table'), 'No active cases')).toBe(true)
      })
    })

    describe('tables with scroll enabled', () => {
      beforeEach(() => {
        initializeDocumentWithTable('case_contacts')
      })

      test("case contacts table renders with 'width=100%'", () => {
        /* This test ensures we retain the css workaround
        *  to the "DataTables with scroll enabled result in
        *  column/header misalignment" bug
        *  (see https://datatables.net/manual/tech-notes/6)
        */
        $('table').each(function () {
          expect($(this).css('width')).toEqual('100%')
        })
        expect($('.dataTables_scrollHeadInner').css('width')).toEqual('100%')
      })
    })
  })
})
