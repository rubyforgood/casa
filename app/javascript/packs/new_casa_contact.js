import $ from 'jquery'
$('document').ready(() => {
  // Ensure at least one casa_case checkbox is checked by setting required to false
  $("input:checkbox.casa-case-id-check").on('click', function() {
    var case_id_checkbox_group = $("input:checkbox.casa-case-id-check");
    case_id_checkbox_group.prop('required', true);

    if(case_id_checkbox_group.is(":checked")){
      case_id_checkbox_group.prop('required', false);
    }
  });
})
