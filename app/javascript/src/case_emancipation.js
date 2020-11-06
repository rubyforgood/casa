const savePath = window.location.pathname + '/save'
let notifications;

// Adds or deletes an option from the current casa case
//  @param    {boolean}           isAdding true if adding the option to the case, false if deleting the option from the case
//  @param    {integeri | string} optionId The id of the emancipation option to add or delete
//  @returns  {array} a jQuery jqXHR object. See https://api.jquery.com/jQuery.ajax/#jqXHR
//  @throws   {TypeError}  for a parameter of the incorrect type
//  @throws   {RangeError} if optionId is negative
function addOrDeleteOption(isAdding, optionId){
  // Input check
  if (typeof optionId === 'string') {
    let optionIdAsNum = parseInt(optionId)

    if (!optionIdAsNum) {
      throw new TypeError('Param optionId is not an integer')
    } else if (optionIdAsNum < 0) {
      throw new RangeError('Param optionId cannot be negative')
    }
  } else {
    if(!Number.isInteger(optionId)) {
      throw new TypeError('Param optionId is not an integer')
    } else if (optionId < 0) {
      throw new RangeError('Param optionId cannot be negative')
    }
  }

  // Post request
  return $.post(savePath, {
    option_action: isAdding ? 'add' : 'delete',
    option_id: optionId
  })
}

// Shows an error notification
//  @param    {string}  errorMsg
//  @throws   {TypeError}  for a parameter of the incorrect type
function notifyError(errorMsg) {
  if (typeof errorMsg !== 'string') {
    throw new TypeError('Param errorMsg is not a string')
  }

  notifications.append(`
  <div class="async-failure-indicator">
    Error: ${errorMsg}
    <button class="btn btn-danger btn-sm">×</button>
  </div>`).find('.async-failure-indicator button').click( function () {
    $(this).parent().remove()
  })
}

$('document').ready(() => {
  let waitingSaveOperationCount = 0
  let emancipationSelects = $('.emancipation-select')
  notifications = $('#async-notifications')

  emancipationSelects.each(function() {
    let thisSelect = $(this)

    thisSelect.data('prev', thisSelect.val())
  })

  emancipationSelects.change(function(data) {
    let thisSelect = $(this)

    waitingSaveOperationCount += thisSelect.data().prev ? 1 : 0
    waitingSaveOperationCount += thisSelect.val() ? 1 : 0

    if (thisSelect.data().prev) {
      addOrDeleteOption(false, thisSelect.data().prev)
      .done(function( response ) {
        waitingSaveOperationCount--

        if (thisSelect.val()) {
          addOrDeleteOption(true, thisSelect.val())
          .done(function( response ) {
            console.log(response)
            waitingSaveOperationCount--
          });
        }
      });
    } else if (thisSelect.val()) {
      addOrDeleteOption(true, thisSelect.val())
      .done(function( response ) {
        console.log(response)
        waitingSaveOperationCount--
      });
    }


    thisSelect.data('prev', thisSelect.val());
  })

  $('.emancipation-check-box').change(function() {
    let thisCheckBox = $(this)
    waitingSaveOperationCount++

    if (thisCheckBox.prop('checked')) {
      addOrDeleteOption(true, thisCheckBox.val())
      .done(function( response ) {
        console.log(response)
        waitingSaveOperationCount--
      });
    } else {
      addOrDeleteOption(false, thisCheckBox.val())
      .done(function( response ) {
        console.log(response)
        waitingSaveOperationCount--
      });
    }
  })
})
