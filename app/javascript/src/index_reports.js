/* global $ */
$('document').ready(() => {
  $('input[data-input-type="datepicker"]').datepicker({
    format: 'yyyy-mm-dd'
  })

  // onDateChange update the download report link because the current implementation
  // of CSV download does not work with form submission
  $('input[data-input-type="datepicker"]').on('changeDate', function () {
    const $form = $(this).parents('form')

    const startDate = $form.find('input[name="start_date"]').val()
    const endDate = $form.find('input[name="end_date"]').val()

    const downloadButton = $form.find('a[data-link-type="download-report"]')

    if (startDate > endDate) {
      downloadButton.attr('hidden', true)
      window.alert('Starting from date should be earlier than ending at date!!')
    } else {
      downloadButton.attr('hidden', false)
    }

    const downloadUrl = '/case_contact_reports.csv?' + 'start_date=' + startDate + '&end_date=' + endDate

    downloadButton.attr('href', downloadUrl)
  })
})
