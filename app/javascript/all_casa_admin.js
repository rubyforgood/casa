import './jQueryGlobalizer.js'

require('datatables.net-dt')(null, window.jQuery) // First parameter is the global object. Defaults to window if null

require('./src/all_casa_admin/tables')
require('./src/all_casa_admin/patch_notes')
