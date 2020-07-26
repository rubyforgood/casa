// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")
require("jquery")
require("bootstrap-datepicker")
require('datatables.net-dt')
require("src/case_contact")
require("src/dashboard")
require("src/index_reports")
require("src/new_casa_contact")

import "bootstrap"

window.setTimeout(function() {
  $(".alert").not(".error").fadeTo(1000, 0).slideUp(1000, function() {
    $(this).remove();
  });
}, 2500);

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
