/* eslint-env jest */
'use strict'

require('jest')
var $ = require('jquery')
var dt = require( 'datatables.net' )()
var _ = require('lodash')
global.$ = $
//global.jQuery = $
import { defineCaseContactsTable } from '../src/dashboard'

describe('dashboard.js', () => {
  describe('DataTable tests', () => {
    function initializeDocumentWithTable (id, numberOfRows = 1, classes = '') {
      var mockTable = `<table id=${id} class=${classes}>` +
                      '<thead>' +
                      '<tr> <th>Column1</th> <th>Column2</th> <th>Column3</th> </tr>' +
                      '</thead> <tbody>'
      _.range(numberOfRows).forEach((rowNum) => (
        mockTable += '<tr> ' +
                      `  <td>some data#${rowNum}</td>` +
                      `  <td>other data#${rowNum}</td>` +
                      `  <td>more data#${rowNum}</td> ` +
                      '</tr>'
      ))
      mockTable += '</tbody> </table>'
      document.body.innerHTML = mockTable
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
        initializeDocumentWithTable('case_contacts', 1, 'case-contacts-table')
        defineCaseContactsTable()
      })

      test("case contacts table renders with 'width=100%'", () => {
        /* This test ensures we retain the css workaround
        *  to the "DataTables with scroll enabled result in
        *  column/header misalignment" bug
        *  (see https://datatables.net/manual/tech-notes/6)
        */
        $('table#case_contacts').each(function () {
          expect($(this).css('width')).toEqual('100%')
        })
        // formatting the DataTables scrollHeadInner makes the styling a
        // bit more responsive, so we should validate its styling too
        expect($('.dataTables_scrollHeadInner').css('width')).toEqual('100%')
      })
    })
  })
})
