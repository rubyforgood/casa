function add_court_mandate_input() {
  const list = "#mandates-list-container"

  const index = $(`${list} textarea`).length
  console.log(index);
  const textarea_html = `<textarea name="casa_case[case_court_mandates_attributes][${index}][mandate_text]"\
id="casa_case_case_court_mandates_attributes_1_mandate_text">\
</textarea>`

  $(list).append(textarea_html)
  $(list).children(":last").trigger("focus")
}

$('document').ready(() => {
  $("span#add-mandate-button").on('click', add_court_mandate_input)
})