/* global window */
import './jQueryGlobalizer.js'
import '@hotwired/turbo-rails'
import 'bootstrap'
import './sweet-alert-confirm.js'
import './controllers'
import 'trix'
import '@rails/actiontext'
import './datatable.js'
Turbo.session.drive = false

require('datatables.net-dt')(null, window.jQuery) // First parameter is the global object. Defaults to window if null
require('select2')(window.jQuery)
require('@rails/ujs').start()
require('@rails/activestorage').start()
require('bootstrap-datepicker')
require('./src/add_to_calendar_button')
require('./src/case_contact')
require('./src/case_emancipation')
require('./src/casa_case')
require('./src/new_casa_case')
require('./src/emancipations')
require('./src/import')
require('./src/password_confirmation')
require('./src/read_more')
require('./src/reports')
require('./src/require_communication_preference')
require('./src/select')
require('./src/tooltip')
require('./src/time_zone')
require('./src/session_timeout_poller.js')
require('./src/sms_reactivation_toggle')
require('./src/validated_form')

// Disable the browser's native HTML5 validation app-wide so an invalid submit reaches the server
// and Rails renders the design-system validation (.field_with_errors rose borders + the
// _form_errors summary) instead of the unstyleable native bubbles. Turbo Drive is off, so this
// runs on each full page load (DOMContentLoaded) plus any Turbo frame/render. Opt a single form
// back into native validation with data-native-validation.
const disableNativeFormValidation = () => {
  document.querySelectorAll('form:not([data-native-validation])').forEach((form) => {
    form.noValidate = true
  })
}
if (document.readyState !== 'loading') disableNativeFormValidation()
document.addEventListener('DOMContentLoaded', disableNativeFormValidation)
document.addEventListener('turbo:load', disableNativeFormValidation)
document.addEventListener('turbo:frame-load', disableNativeFormValidation)
