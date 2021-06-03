/* global $ */

$('document').ready(() => {
  $('.select2').select2({ theme: 'classic', matcher: matchCustom })
})

function matchCustom(params, data) {
  // If there are no search terms, return all of the data
  if ($.trim(params.term) === '') {
    return data;
  }

  // Do not display the item if there is no 'text' property
  if (typeof data.text === 'undefined') {
    return null;
  }

  // `params.term` should be the term that is used for searching
  // `data.text` is the text that is displayed for the data object
  if (data.text.toUpperCase().indexOf(params.term.toUpperCase()) > -1) {
    return data;
  }

  // custom search using lookup data
  var lookup = $(data.element).data('lookup');
  if (lookup && lookup.toUpperCase().indexOf(params.term.toUpperCase()) > -1) {
    return data;
  }

  // Return `null` if the term should not be displayed
  return null;
}

