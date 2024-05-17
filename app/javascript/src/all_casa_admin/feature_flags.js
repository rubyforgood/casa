$(function () {
  const checkboxes = $('.form-check-input.toggle-switch')

  checkboxes.on('change', function (e) {
    e.preventDefault()
    const featureFlagId = $(this).data('feature-flag-id')
    const uniqueCheckbox = $('#feature-checkbox-' + featureFlagId)
    const csrfToken = $('meta[name=csrf-token]').attr('content')
    const isChecked = this.checked
    toggleSwitch(uniqueCheckbox, csrfToken, featureFlagId, isChecked)
  })

  function toggleSwitch (uniqueCheckbox, csrfToken, featureFlagId, checked) {
    $.ajax({
      url: `/all_casa_admins/feature_flags/${featureFlagId}`,
      method: 'PATCH',
      contentType: 'application/json',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      success: function () {
        if (checked) {
          uniqueCheckbox.prop('checked', true)
        } else {
          uniqueCheckbox.prop('checked', false)
        }
      }
    })
  }
})
