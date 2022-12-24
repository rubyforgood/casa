/* global window */

import 'bootstrap'
import 'bootstrap-select'
import './jQueryGlobalizer.js'
import './sweet-alert-confirm.js'

require('datatables.net-dt')(null, window.jQuery) // First parameter is the global object. Defaults to window if null
require('select2')(window.jQuery)

require('@rails/ujs').start()
require('@rails/activestorage').start()

require('bootstrap-datepicker')

require('./src/add_additional_expense')
require('./src/add_to_calendar_button')
require('./src/case_contact')
require('./src/case_contact_autosave')
require('./src/case_emancipation')
require('./src/casa_case')
require('./src/new_casa_case')
require('./src/dashboard')
require('./src/emancipations')
require('./src/import')
require('./src/password_confirmation')
require('./src/plainadmin')
require('./src/email_confirmation')
require('./src/read_more')
require('./src/reimbursements')
require('./src/reports')
require('./src/require_communication_preference')
require('./src/select')
require('./src/sidebar')
require('./src/tooltip')
