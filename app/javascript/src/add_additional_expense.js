// $(document).on("click", "#add-another-expense", function() {
//   $(".hide-field").show();
// });

$(document).on("click", "#add-another-expense", function() {
  if ($("#case_contact_additional_expenses_attributes_0_other_expense_amount").length > 0) {
    console.log("0 detected")
    const elementAmount = document.getElementById("case_contact_additional_expenses_attributes_1_other_expense_amount")
    elementAmount.classList.remove('hide-field')
    const elementDescribe = document.getElementById("case_contact_additional_expenses_attributes_1_other_expenses_describe")
    elementDescribe.classList.remove('hide-field')
    $("case_contact_additional_expenses_attributes_1_other_expenses_describe").classList.remove('hide-field')
  }
});

// if (document.body.contains("#case_contact_additional_expenses_attributes_0_other_expense_amount")) {
