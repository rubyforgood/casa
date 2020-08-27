import $ from 'jquery'
$('document').ready(() => {
  // Ensure at least one casa_case checkbox is checked by setting required to false
  $('input:checkbox.casa-case-id-check').on('click', function () {
    var caseIdCheckboxGroup = $('input:checkbox.casa-case-id-check')
    caseIdCheckboxGroup.prop('required', true)

    if (caseIdCheckboxGroup.is(':checked')) {
      caseIdCheckboxGroup.prop('required', false)
    }
  })
})
