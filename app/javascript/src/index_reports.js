/* global $ */
$('document').ready(() => {
  $('input[data-input-type="datepicker"]').datepicker({
    format: 'yyyy-mm-dd'
  })

  // onDateChange update the download report link because the current implementation
  // of CSV download does not work with form submission
  $('input[data-input-type="datepicker"]').on('changeDate', function () {
    const $form = $(this).parents('form')

    const startDate = $form.find('input[name="startDate"]').val()
    const endDate = $form.find('input[name="endDate"]').val()

    const downloadButton = $form.find('a[data-link-type="download-report"]')
    const downloadUrl = '/case_contact_reports.csv?' + 'startDate=' + startDate + '&endDate=' + endDate

    downloadButton.attr('href', downloadUrl)
  })
})
