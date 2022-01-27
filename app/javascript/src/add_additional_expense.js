$(document).on("click", "#add-another-expense", function() {
  for (let i=1; i < 10; i++) {
    if ($(`#case_contact_additional_expenses_attributes_${i}_other_expense_amount`).is(":hidden")) {
      $(`#case_contact_additional_expenses_attributes_${i}_other_expense_amount`).show();
      $(`#case_contact_additional_expenses_attributes_${i}_other_expenses_describe`).show();
      break;
    }
  }
});

