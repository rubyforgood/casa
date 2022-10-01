/* global window */

import './jQueryGlobalizer.js'
import 'bootstrap'
import 'bootstrap-select'
import './sweet-alert-confirm.js'

require('datatables.net-dt')(null, window.jQuery) // First parameter is the global object. Defaults to window if null
require('select2')(window.jQuery)

require('@rails/ujs').start()
require('@rails/activestorage').start()

require('bootstrap-datepicker')

require('./src/add_additional_expense')
require('./src/addToCalendarButton')
require('./src/case_contact')
require('./src/case_contact_autosave')
require('./src/case_emancipation')
require('./src/casa_case')
require('./src/dashboard')
require('./src/emancipations')
require('./src/require_communication_preference')
require('./src/import')
require('./src/password_confirmation')
require('./src/readMore')
require('./src/reports')
require('./src/select')
require('./src/sidebar')
require('./src/tooltip')
require('./src/reimbursements')
