// the problems to solve:
// 1. how to invoke a request to the controller action to update value of enabled
// 2. how to persist the state of the switch upon a refresh

// Get all the checkboxes with a class of 'form-check-input'

// document.addEventListener('DOMContentLoaded', function() {
// let checkboxes = document.querySelectorAll('.form-check-input.toggle-switch');

// checkboxes.forEach(function(checkbox) {
//   checkbox.addEventListener('change', function(e) {
//     e.preventDefault();
//     e.stopPropagation()
//     // Get the feature_flag_id from the data attribute
//     let featureFlagId = this.getAttribute('data-feature-flag-id');
//     let uniqueCheckbox = document.getElementById('feature-checkbox-' + featureFlagId);
//     const csrfToken = document.querySelector("meta[name=csrf-token]").getAttribute("content");
//     const isChecked = this.checked;
//     toggleSwitch(uniqueCheckbox, csrfToken, featureFlagId, isChecked)
//   });
// });


// function toggleSwitch(uniqueCheckbox, csrfToken, featureFlagId, checked){
//   // if (uniqueCheckbox) {
//     // uniqueCheckbox.checked = !uniqueCheckbox.checked;
//     fetch(`/all_casa_admins/feature_flags/${featureFlagId}`, {
//       method: 'PATCH',
//       headers: {
//         'Content-Type': 'application/json',
//         'X-CSRF-Token': csrfToken
//       }
//     })
//     .then(() => {
//       if (checked){
//         uniqueCheckbox.checked = true
//       } else {
//         uniqueCheckbox.checked = false
//       }
//     })
//   // }
// }
// })


$(function() {
  let checkboxes = $('.form-check-input.toggle-switch');

  checkboxes.on('change', function(e) {
    e.preventDefault();
    let featureFlagId = $(this).data('feature-flag-id');
    let uniqueCheckbox = $('#feature-checkbox-' + featureFlagId);
    const csrfToken = $('meta[name=csrf-token]').attr('content');
    const isChecked = this.checked;
    toggleSwitch(uniqueCheckbox, csrfToken, featureFlagId, isChecked);
  });

  function toggleSwitch(uniqueCheckbox, csrfToken, featureFlagId, checked) {
      $.ajax({
        url: `/all_casa_admins/feature_flags/${featureFlagId}`,
        method: 'PATCH',
        contentType: 'application/json',
        headers: {
          'X-CSRF-Token': csrfToken
        },
        success: function() {
          if (checked) {
            uniqueCheckbox.prop('checked', true);
          } else {
            uniqueCheckbox.prop('checked', false);
          }
        }
      });
    }
});