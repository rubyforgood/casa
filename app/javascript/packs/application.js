// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
/* global $ */

// this is how stylesheets are loaded into the running application
import 'src/stylesheets/application.scss'

import 'bootstrap'
import 'bootstrap-select'

require('@rails/ujs').start()
require('@rails/activestorage').start()
require('channels')
require('jquery')
require('bootstrap-datepicker')
require('datatables.net-dt')
require('datatables.net-dt/css/jquery.dataTables.css')
require('src/case_contact')
require('src/dashboard')
require('src/index_reports')
require('src/sessions')

window.setTimeout(function () {
  $('.alert')
    .not('.error')
    .fadeTo(1000, 0)
    .slideUp(1000, function () {
      $(this).remove()
    })
}, 2500)

// Uncomment to copy all static images under ../images to the output folder and
// reference them with the image_pack_tag or asset_pack_path helpers in views.
// See app/views/shared/_favicons.html.erb for reference.
//
// NOTE: all image asset url helpers in Rails views must prefix image/$blah with media/src/.
// TODO: figure out why?
const images = require.context('../src/images', true) // eslint-disable-line no-unused-vars

//
