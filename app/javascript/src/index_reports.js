$('document').ready(() => {
  $('input[data-input-type="datepicker"]').datepicker({
    format: 'yyyy-mm-dd'
  });

  // onDateChange update the download report link because the current implementation
  // of CSV download does not work with form submission
  $('input[data-input-type="datepicker"]').on('changeDate', function() {
    let $form = $(this).parents('form');

    let start_date = $form.find('input[name="start_date"]').val()
    let end_date = $form.find('input[name="end_date"]').val()

    let download_button = $form.find('a[data-link-type="download-report"]')
    let download_url = '/case_contact_reports.csv?' + 'start_date=' + start_date + '&end_date=' + end_date

    download_button.attr('href', download_url)
  });
});
