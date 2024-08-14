/* global window */
/* global $ */
/* eslint-disable */

import Swal from "sweetalert2";

function enGBDateString(date) {
  return date.toLocaleDateString("en-GB").split("/").reverse().join("-");
}

function convertDateToSystemTimeZone(date) {
  return new Date(typeof date === "string" ? new Date(date) : date);
}

async function displayFollowupAlert(followupableType, followupableId) {
  const { value: text, isConfirmed } = await fireSwalFollowupAlert();
  if (!isConfirmed) return;

  const params = {
    note: text,
    followupable_type: followupableType,
    followupable_id: followupableId,
  };
  $.post(`/followups`, params, () => window.location.reload());
}

async function fireSwalFollowupAlert() {
  const inputLabel = "Optional: Add a note about what followup is needed.";

  return await Swal.fire({
    input: "textarea",
    title: inputLabel,
    inputPlaceholder: "Type your note here...",
    inputAttributes: { "aria-label": "Type your note here" },

    showCancelButton: true,
    showCloseButton: true,

    confirmButtonText: "Confirm",
    confirmButtonColor: "#dc3545",

    customClass: {
      inputLabel: "mx-5",
    },
  });
}

$(() => {
  // JQuery's callback for the DOM loading
  const caseOccurredAt = $("#case_contact_occurred_at");
  const timeZoneConvertedDate = enGBDateString(new Date());

  if (enGBDateString(convertDateToSystemTimeZone(caseOccurredAt.val())) === timeZoneConvertedDate) {
    caseOccurredAt.val(timeZoneConvertedDate);
  }

  $('[data-toggle="tooltip"]').tooltip();
  $(".followup-button").on("click", function (event) {
    const followupableType = $(this).data("followupable-type");
    const followupableId = $(this).data("followupable-id");
    displayFollowupAlert(followupableType, followupableId);
  });
});

export { convertDateToSystemTimeZone };
