import $ from 'jquery'
$('document').ready(() => {
  // inside the app/views/casa_contact/_form, we are trying to only show a field if 'other' is chosen.
  $("#contact_type").change((e) => {
    if (e.target.value === 'other') {
      $(".other-contact-type").removeAttr('hidden')
      $(".other-contact-type input").attr('required', 'required')
    } else {
      $(".other-contact-type").attr('hidden', true)
      $(".other-contact-type input").removeAttr('required')
    }
  })

  // Ensure at least one casa_case checkbox is checked by setting required to false
  $("input:checkbox.casa-case-id-check").on('click', function() {
    var case_id_checkbox_group = $("input:checkbox.casa-case-id-check");
    case_id_checkbox_group.prop('required', true);

    if(case_id_checkbox_group.is(":checked")){
      case_id_checkbox_group.prop('required', false);
    }
  });
})
