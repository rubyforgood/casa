// (window).on('load', function() {
//   $('.form-check-input').on('change', function() {
//     debugger
//     const featureFlagId = $(this).data('feature-flag-id');
//     const isChecked = $(this).prop('checked');

//     // Send an AJAX request to update the feature flag state in the database
//     $.ajax({
//       type: 'POST',
//       url: '/feature_flags/update', // Define the route in your application
//       data: { id: featureFlagId, enabled: isChecked },
//       success: function(data) {
//         // Handle success, if needed
//       },
//       error: function(err) {
//         // Handle errors, if needed
//       }
//     });
//   });
// });


document.addEventListener("DOMContentLoaded", () => {
  // debugger
  console.log("test!")
})

// debugger

// the problems to solve:
// 1. how to invoke a request to the controller action to update value of enabled
// 2. how to persist the state of the switch upon a refresh
