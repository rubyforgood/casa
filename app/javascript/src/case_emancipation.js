$('document').ready(() => {
  let waitingSaveOperationCount = 0

  $('.emancipation_select').each(function() {
    let thisSelect = $(this)
    thisSelect.data('prev', thisSelect.val())
  })

  $('.emancipation_select').change(function(data) {
    let thisSelect = $(this)

    waitingSaveOperationCount += 2

    if (thisSelect.data().prev) {
      $.post(window.location.pathname + '/save', {
        option_action: 'delete',
        option_id: thisSelect.data().prev
      })
      .done(function( response ) {
        waitingSaveOperationCount--
      });
    }

    $.post(window.location.pathname + "/save", 
    {
      option_action: 'add',
      option_id: $(this).val()
    })
    .done(function( response ) {
      console.log(response)
      waitingSaveOperationCount--
    });

    thisSelect.data('prev', thisSelect.val());
  })
})
