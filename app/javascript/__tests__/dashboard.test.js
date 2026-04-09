/* eslint-env jest */
/**
 * @jest-environment jsdom
 */

import Swal from 'sweetalert2'
import { defineCaseContactsTable } from '../src/dashboard'

jest.mock('sweetalert2', () => ({
  __esModule: true,
  default: { fire: jest.fn() }
}))

// Mock DataTable
const mockDataTable = jest.fn()
$.fn.DataTable = mockDataTable

describe('defineCaseContactsTable', () => {
  let tableElement

  beforeEach(() => {
    // Reset mocks
    mockDataTable.mockClear()

    // Set up DOM
    document.body.innerHTML = `
      <table id="case_contacts" data-source="/case_contacts/new_design/datatable.json">
        <thead>
          <tr>
            <th></th>
            <th></th>
            <th>Date</th>
            <th>Case</th>
            <th>Relationship</th>
            <th>Medium</th>
            <th>Created By</th>
            <th>Contacted</th>
            <th>Topics</th>
            <th>Draft</th>
            <th></th>
          </tr>
        </thead>
        <tbody></tbody>
      </table>
    `

    tableElement = $('table#case_contacts')
  })

  describe('DataTable initialization', () => {
    it('initializes DataTable on the case_contacts table', () => {
      defineCaseContactsTable()

      expect(mockDataTable).toHaveBeenCalledTimes(1)
      expect(mockDataTable.mock.instances[0][0]).toBe(tableElement[0])
    })

    it('configures DataTable with server-side processing', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]

      expect(config.serverSide).toBe(true)
      expect(config.processing).toBe(true)
      expect(config.searching).toBe(true)
    })

    it('configures scrollX for horizontal scrolling', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]

      expect(config.scrollX).toBe(true)
    })

    it('sets default sort to Date column descending', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]

      expect(config.order).toEqual([[2, 'desc']])
    })

    it('disables ordering on bell, chevron, and ellipsis columns', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]

      expect(config.columnDefs).toEqual([
        { orderable: false, targets: [0, 1, 10] }
      ])
    })
  })

  describe('AJAX configuration', () => {
    it('uses the data-source URL from the table', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]

      expect(config.ajax.url).toBe('/case_contacts/new_design/datatable.json')
      expect(config.ajax.type).toBe('POST')
      expect(config.ajax.dataType).toBe('json')
    })

    it('includes error handler for AJAX requests', () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation()

      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]
      const mockError = 'Network error'
      const mockCode = 500

      config.ajax.error({}, mockError, mockCode)

      expect(consoleErrorSpy).toHaveBeenCalledWith('DataTable error:', mockError, mockCode)

      consoleErrorSpy.mockRestore()
    })
  })

  describe('column configurations', () => {
    let columns

    beforeEach(() => {
      defineCaseContactsTable()
      columns = mockDataTable.mock.calls[0][0].columns
    })

    it('configures 11 columns', () => {
      expect(columns).toHaveLength(11)
    })

    describe('Bell icon column (index 0)', () => {
      it('is not orderable or searchable', () => {
        expect(columns[0].orderable).toBe(false)
        expect(columns[0].searchable).toBe(false)
      })

      it('renders filled bell icon when has_followup is "true"', () => {
        const rendered = columns[0].render('true', 'display', {})

        expect(rendered).toBe('<i class="fas fa-bell"></i>')
      })

      it('renders faded bell icon when has_followup is "false"', () => {
        const rendered = columns[0].render('false', 'display', {})

        expect(rendered).toBe('<i class="fas fa-bell" style="opacity: 0.3;"></i>')
      })
    })

    describe('Chevron icon column (index 1)', () => {
      it('is not orderable or searchable', () => {
        expect(columns[1].orderable).toBe(false)
        expect(columns[1].searchable).toBe(false)
      })

      it('renders chevron-down icon as an accessible button', () => {
        const rendered = columns[1].render(null, 'display', {})

        expect(rendered).toBe('<button type="button" class="expand-toggle" aria-expanded="false" aria-label="Expand row details"><i class="fa-solid fa-chevron-down" aria-hidden="true"></i></button>')
      })
    })

    describe('Date column (index 2)', () => {
      it('uses occurred_at data field', () => {
        expect(columns[2].data).toBe('occurred_at')
        expect(columns[2].name).toBe('occurred_at')
      })

      it('renders date string or empty string', () => {
        expect(columns[2].render('January 15, 2024')).toBe('January 15, 2024')
        expect(columns[2].render(null)).toBe('')
        expect(columns[2].render('')).toBe('')
      })
    })

    describe('Case column (index 3)', () => {
      it('is not orderable', () => {
        expect(columns[3].orderable).toBe(false)
      })

      it('renders link to casa_case when data exists', () => {
        const data = { id: '123', case_number: 'CASA-2024-001' }
        const rendered = columns[3].render(data, 'display', {})

        expect(rendered).toBe('<a href="/casa_cases/123">CASA-2024-001</a>')
      })

      it('renders empty string when casa_case is null', () => {
        expect(columns[3].render(null, 'display', {})).toBe('')
      })

      it('renders empty string when casa_case has no id', () => {
        const data = { id: null, case_number: 'CASA-2024-001' }

        expect(columns[3].render(data, 'display', {})).toBe('')
      })
    })

    describe('Relationship (Contact Types) column (index 4)', () => {
      it('is not orderable', () => {
        expect(columns[4].orderable).toBe(false)
      })

      it('renders contact types string', () => {
        expect(columns[4].render('Family, School')).toBe('Family, School')
        expect(columns[4].render(null)).toBe('')
      })
    })

    describe('Medium column (index 5)', () => {
      it('renders medium type', () => {
        expect(columns[5].render('In-person')).toBe('In-person')
        expect(columns[5].render('Text/Email')).toBe('Text/Email')
        expect(columns[5].render(null)).toBe('')
      })
    })

    describe('Created By column (index 6)', () => {
      it('is not orderable', () => {
        expect(columns[6].orderable).toBe(false)
      })

      it('renders empty string when creator is null', () => {
        expect(columns[6].render(null, 'display', {})).toBe('')
      })

      it('renders link to volunteer edit page for volunteers', () => {
        const data = {
          id: '456',
          display_name: 'John Doe',
          role: 'Volunteer'
        }
        const rendered = columns[6].render(data, 'display', {})

        expect(rendered).toBe('<a href="/volunteers/456/edit" data-turbo="false">John Doe</a>')
      })

      it('renders link to supervisor edit page for supervisors', () => {
        const data = {
          id: '789',
          display_name: 'Jane Smith',
          role: 'Supervisor'
        }
        const rendered = columns[6].render(data, 'display', {})

        expect(rendered).toBe('<a href="/supervisors/789/edit" data-turbo="false">Jane Smith</a>')
      })

      it('renders link to users edit page for casa admins', () => {
        const data = {
          id: '999',
          display_name: 'Admin User',
          role: 'Casa Admin'
        }
        const rendered = columns[6].render(data, 'display', {})

        expect(rendered).toBe('<a href="/users/edit" data-turbo="false">Admin User</a>')
      })
    })

    describe('Contacted column (index 7)', () => {
      it('is not orderable', () => {
        expect(columns[7].orderable).toBe(false)
      })

      it('renders checkmark icon when contact was made', () => {
        const row = { contact_made: 'true', duration_minutes: null }
        const rendered = columns[7].render('true', 'display', row)

        expect(rendered).toContain('<i class="lni lni-checkmark-circle" style="color: green;"></i>')
      })

      it('renders cross icon when contact was not made', () => {
        const row = { contact_made: 'false', duration_minutes: null }
        const rendered = columns[7].render('false', 'display', row)

        expect(rendered).toContain('<i class="lni lni-cross-circle" style="color: orange;"></i>')
      })

      it('includes formatted duration when present', () => {
        const row = { contact_made: 'true', duration_minutes: 90 }
        const rendered = columns[7].render('true', 'display', row)

        expect(rendered).toContain('(01:30)')
      })

      it('formats duration with leading zeros', () => {
        const row = { contact_made: 'true', duration_minutes: 5 }
        const rendered = columns[7].render('true', 'display', row)

        expect(rendered).toContain('(00:05)')
      })

      it('handles hours and minutes correctly', () => {
        const row = { contact_made: 'true', duration_minutes: 125 }
        const rendered = columns[7].render('true', 'display', row)

        expect(rendered).toContain('(02:05)')
      })

      it('does not include duration when not present', () => {
        const row = { contact_made: 'true', duration_minutes: null }
        const rendered = columns[7].render('true', 'display', row)

        expect(rendered).not.toContain('(')
      })
    })

    describe('Topics column (index 8)', () => {
      it('is not orderable', () => {
        expect(columns[8].orderable).toBe(false)
      })

      it('renders each topic as a pill badge', () => {
        const rendered = columns[8].render(['Topic 1', 'Topic 2'])
        expect(rendered).toContain('<span class="badge badge-pill light-bg text-black">Topic 1</span>')
        expect(rendered).toContain('<span class="badge badge-pill light-bg text-black">Topic 2</span>')
      })

      it('renders empty string when there are no topics', () => {
        expect(columns[8].render(null)).toBe('')
        expect(columns[8].render([])).toBe('')
      })

      it('shows only the first two topics when there are more than two', () => {
        const rendered = columns[8].render(['A', 'B', 'C', 'D'])
        expect(rendered).toContain('>A<')
        expect(rendered).toContain('>B<')
        expect(rendered).not.toContain('>C<')
        expect(rendered).not.toContain('>D<')
      })

      it('shows a +N More badge for overflow topics', () => {
        const rendered = columns[8].render(['A', 'B', 'C', 'D'])
        expect(rendered).toContain('+2 More')
      })

      it('does not show an overflow badge when there are two or fewer topics', () => {
        expect(columns[8].render(['A', 'B'])).not.toContain('More')
        expect(columns[8].render(['A'])).not.toContain('More')
      })
    })

    describe('Draft column (index 9)', () => {
      it('is not orderable', () => {
        expect(columns[9].orderable).toBe(false)
      })

      it('renders Draft badge when is_draft is true', () => {
        const rendered = columns[9].render(true, 'display', {})

        expect(rendered).toBe('<span class="badge badge-pill light-bg text-black" data-testid="draft-badge">Draft</span>')
      })

      it('renders empty string when is_draft is false', () => {
        const rendered = columns[9].render(false, 'display', {})

        expect(rendered).toBe('')
      })

      it('handles string "true" as truthy', () => {
        const rendered = columns[9].render('true', 'display', {})

        expect(rendered).toBe('<span class="badge badge-pill light-bg text-black" data-testid="draft-badge">Draft</span>')
      })

      it('handles string "false" as falsy (explicit check for "true")', () => {
        const rendered = columns[9].render('false', 'display', {})

        // With explicit check for === true || === "true", string "false" should not render badge
        expect(rendered).toBe('')
      })

      it('handles empty string as falsy', () => {
        const rendered = columns[9].render('', 'display', {})

        expect(rendered).toBe('')
      })
    })

    describe('Ellipsis menu column (index 10)', () => {
      it('is not orderable or searchable', () => {
        expect(columns[10].orderable).toBe(false)
        expect(columns[10].searchable).toBe(false)
      })

      it('renders a button toggle with aria-label containing the contact date', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'true', can_destroy: 'true', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('class="fas fa-ellipsis-v"')
        expect(rendered).toContain('aria-label="Actions for case contact on July 01, 2024"')
        expect(rendered).toContain('type="button"')
      })

      it('renders the ellipsis icon as aria-hidden', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'true', can_destroy: 'true', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('aria-hidden="true"')
      })

      it('renders Edit item when can_edit is "true"', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'true', can_destroy: 'false', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('href="/case_contacts/1/edit"')
        expect(rendered).toContain('Edit')
      })

      it('renders Edit as disabled when can_edit is "false"', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'false', can_destroy: 'false', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('Edit')
        expect(rendered).toContain('disabled')
        expect(rendered).toContain('aria-disabled="true"')
        expect(rendered).not.toContain('href="/case_contacts/1/edit"')
      })

      it('renders Delete item when can_destroy is "true"', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'false', can_destroy: 'true', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('cc-delete-action')
        expect(rendered).toContain('data-id="1"')
        expect(rendered).toContain('Delete')
      })

      it('renders Delete as disabled when can_destroy is "false"', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'false', can_destroy: 'false', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('Delete')
        expect(rendered).toContain('disabled')
        expect(rendered).toContain('aria-disabled="true"')
        expect(rendered).not.toContain('cc-delete-action')
      })

      it('renders Set Reminder when followup_id is empty', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'false', can_destroy: 'false', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('cc-set-reminder-action')
        expect(rendered).toContain('Set Reminder')
        expect(rendered).not.toContain('Resolve Reminder')
      })

      it('renders Resolve Reminder when followup_id is present', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'false', can_destroy: 'false', edit_path: '/case_contacts/1/edit', followup_id: '42' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toContain('cc-resolve-reminder-action')
        expect(rendered).toContain('data-followup-id="42"')
        expect(rendered).toContain('Resolve Reminder')
        expect(rendered).not.toContain('Set Reminder')
      })

      it('always renders the reminder menu item', () => {
        const row = { id: '1', occurred_at: 'July 01, 2024', can_edit: 'false', can_destroy: 'false', edit_path: '/case_contacts/1/edit', followup_id: '' }
        const rendered = columns[10].render(null, 'display', row)

        expect(rendered).toMatch(/Set Reminder|Resolve Reminder/)
      })
    })
  })

  describe('click handlers', () => {
    let mockAjaxReload
    let mockTableInstance

    beforeEach(() => {
      mockAjaxReload = jest.fn()
      mockTableInstance = { ajax: { reload: mockAjaxReload } }
      mockDataTable.mockReturnValue(mockTableInstance)

      // Add CSRF meta tag
      document.head.innerHTML = '<meta name="csrf-token" content="test-csrf-token">'

      defineCaseContactsTable()
    })

    afterEach(() => {
      Swal.fire.mockReset()
    })

    describe('Delete action', () => {
      it('shows a SweetAlert confirmation dialog when cc-delete-action is clicked', () => {
        Swal.fire.mockResolvedValue({ isConfirmed: false })

        $('table#case_contacts tbody').append('<tr><td><button class="cc-delete-action" data-id="42">Delete</button></td></tr>')
        $('.cc-delete-action').trigger('click')

        expect(Swal.fire).toHaveBeenCalled()
      })

      it('sends DELETE request when confirmed', async () => {
        Swal.fire.mockResolvedValue({ isConfirmed: true })
        const ajaxSpy = jest.spyOn($, 'ajax').mockImplementation(({ success }) => success && success())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-delete-action" data-id="42">Delete</button></td></tr>')
        $('.cc-delete-action').trigger('click')

        await Promise.resolve()

        expect(ajaxSpy).toHaveBeenCalledWith(expect.objectContaining({
          url: '/case_contacts/42',
          type: 'DELETE',
          dataType: 'json',
          headers: { 'X-CSRF-Token': 'test-csrf-token' }
        }))

        ajaxSpy.mockRestore()
      })

      it('does not send DELETE request when cancelled', async () => {
        Swal.fire.mockResolvedValue({ isConfirmed: false })
        const ajaxSpy = jest.spyOn($, 'ajax').mockImplementation()

        $('table#case_contacts tbody').append('<tr><td><button class="cc-delete-action" data-id="42">Delete</button></td></tr>')
        $('.cc-delete-action').trigger('click')

        await Promise.resolve()

        expect(ajaxSpy).not.toHaveBeenCalled()

        ajaxSpy.mockRestore()
      })

      it('reloads the DataTable after successful delete', async () => {
        Swal.fire.mockResolvedValue({ isConfirmed: true })
        jest.spyOn($, 'ajax').mockImplementation(({ success }) => success && success())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-delete-action" data-id="42">Delete</button></td></tr>')
        $('.cc-delete-action').trigger('click')

        await Promise.resolve()

        expect(mockAjaxReload).toHaveBeenCalled()
      })
    })

    describe('Set Reminder action', () => {
      it('fires SweetAlert when cc-set-reminder-action is clicked', () => {
        Swal.fire.mockResolvedValue({ isConfirmed: false })

        $('table#case_contacts tbody').append('<tr><td><button class="cc-set-reminder-action" data-id="5">Set Reminder</button></td></tr>')
        $('.cc-set-reminder-action').trigger('click')

        expect(Swal.fire).toHaveBeenCalled()
      })

      it('posts to the followups endpoint when confirmed without a note', async () => {
        Swal.fire.mockResolvedValue({ value: '', isConfirmed: true })
        const postSpy = jest.spyOn($, 'post').mockImplementation((_url, _params, cb) => cb && cb())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-set-reminder-action" data-id="5">Set Reminder</button></td></tr>')
        $('.cc-set-reminder-action').trigger('click')

        await Promise.resolve()

        expect(postSpy).toHaveBeenCalledWith('/case_contacts/5/followups', {}, expect.any(Function))

        postSpy.mockRestore()
      })

      it('posts with note when confirmed with a note', async () => {
        Swal.fire.mockResolvedValue({ value: 'My note', isConfirmed: true })
        const postSpy = jest.spyOn($, 'post').mockImplementation((_url, _params, cb) => cb && cb())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-set-reminder-action" data-id="5">Set Reminder</button></td></tr>')
        $('.cc-set-reminder-action').trigger('click')

        await Promise.resolve()

        expect(postSpy).toHaveBeenCalledWith('/case_contacts/5/followups', { note: 'My note' }, expect.any(Function))

        postSpy.mockRestore()
      })

      it('does not post when cancelled', async () => {
        Swal.fire.mockResolvedValue({ isConfirmed: false })
        const postSpy = jest.spyOn($, 'post').mockImplementation()

        $('table#case_contacts tbody').append('<tr><td><button class="cc-set-reminder-action" data-id="5">Set Reminder</button></td></tr>')
        $('.cc-set-reminder-action').trigger('click')

        await Promise.resolve()

        expect(postSpy).not.toHaveBeenCalled()

        postSpy.mockRestore()
      })

      it('reloads the DataTable after creating a reminder', async () => {
        Swal.fire.mockResolvedValue({ value: '', isConfirmed: true })
        jest.spyOn($, 'post').mockImplementation((_url, _params, cb) => cb && cb())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-set-reminder-action" data-id="5">Set Reminder</button></td></tr>')
        $('.cc-set-reminder-action').trigger('click')

        await Promise.resolve()

        expect(mockAjaxReload).toHaveBeenCalled()
      })
    })

    describe('Resolve Reminder action', () => {
      it('sends PATCH request when cc-resolve-reminder-action is clicked', () => {
        const ajaxSpy = jest.spyOn($, 'ajax').mockImplementation(({ success }) => success && success())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-resolve-reminder-action" data-id="5" data-followup-id="42">Resolve Reminder</button></td></tr>')
        $('.cc-resolve-reminder-action').trigger('click')

        expect(ajaxSpy).toHaveBeenCalledWith(expect.objectContaining({
          url: '/followups/42/resolve',
          type: 'PATCH',
          dataType: 'json',
          headers: { 'X-CSRF-Token': 'test-csrf-token' }
        }))

        ajaxSpy.mockRestore()
      })

      it('reloads the DataTable after resolving a reminder', () => {
        jest.spyOn($, 'ajax').mockImplementation(({ success }) => success && success())

        $('table#case_contacts tbody').append('<tr><td><button class="cc-resolve-reminder-action" data-id="5" data-followup-id="42">Resolve Reminder</button></td></tr>')
        $('.cc-resolve-reminder-action').trigger('click')

        expect(mockAjaxReload).toHaveBeenCalled()
      })
    })
  })

  describe('edge cases', () => {
    it('handles missing data-source attribute gracefully', () => {
      tableElement.removeAttr('data-source')

      expect(() => defineCaseContactsTable()).not.toThrow()

      const config = mockDataTable.mock.calls[0][0]
      expect(config.ajax.url).toBeUndefined()
    })

    it('handles table element not existing', () => {
      document.body.innerHTML = ''

      // Should not throw when table doesn't exist
      expect(() => defineCaseContactsTable()).not.toThrow()
    })
  })

  describe('DataTable integration', () => {
    it('passes all required configuration options', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]

      // Verify all critical config options are present
      expect(config).toHaveProperty('scrollX')
      expect(config).toHaveProperty('searching')
      expect(config).toHaveProperty('processing')
      expect(config).toHaveProperty('serverSide')
      expect(config).toHaveProperty('order')
      expect(config).toHaveProperty('ajax')
      expect(config).toHaveProperty('columnDefs')
      expect(config).toHaveProperty('columns')
    })

    it('configures columns array matching table structure', () => {
      defineCaseContactsTable()

      const config = mockDataTable.mock.calls[0][0]
      const headerColumns = $('table#case_contacts thead th').length

      expect(config.columns.length).toBe(headerColumns)
    })
  })
})
