// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// this is how stylesheets are loaded into the running application

import 'src/stylesheets/application.scss'

import 'bootstrap'
import 'bootstrap-select'
import '../sweet-alert-confirm'
require('@rails/ujs').start()
require('@rails/activestorage').start()
require('channels')

require('jquery')
require('bootstrap-datepicker')
require('datatables.net-dt')
require('datatables.net-dt/css/jquery.dataTables.css')
require('select2')
require('select2/dist/css/select2')

require('src/case_contact')
require('src/case_contact_autosave')
require('src/case_emancipation')
require('src/casa_case')
require('src/emancipations')
require('src/select')
require('src/dashboard')
require('src/sidebar')
require('src/readMore')
require('src/tooltip')

// Uncomment to copy all static images under ../images to the output folder and
// reference them with the image_pack_tag or asset_pack_path helpers in views.
// See app/views/shared/_favicons.html.erb for reference.
//
// NOTE: all image asset url helpers in Rails views must prefix image/$blah with media/src/.
// TODO: figure out why?
const images = require.context('../src/images', true) // eslint-disable-line no-unused-vars
