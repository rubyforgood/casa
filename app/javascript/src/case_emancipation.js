const savePath = window.location.pathname + '/save'

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
      $.post(savePath, {
        option_action: 'delete',
        option_id: thisSelect.data().prev
      })
      .done(function( response ) {
        waitingSaveOperationCount--
      });
    }

    $.post(savePath,
    {
      option_action: 'add',
      option_id: thisSelect.val()
    })
    .done(function( response ) {
      console.log(response)
      waitingSaveOperationCount--
    });

    thisSelect.data('prev', thisSelect.val());
  })

  $('.emancipation_check_box').change(function() {
    let thisCheckBox = $(this)

    if (thisCheckBox.prop('checked')) {
      $.post(savePath,
      {
        option_action: 'add',
        option_id: thisCheckBox.val()
      })
      .done(function( response ) {
        console.log(response)
        waitingSaveOperationCount--
      });
    } else {
      $.post(savePath,
      {
        option_action: 'delete',
        option_id: thisCheckBox.val()
      })
      .done(function( response ) {
        console.log(response)
        waitingSaveOperationCount--
      });
    }
  })
})
