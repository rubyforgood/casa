window.onload = function () {
  const milesDriven = document.getElementById("case_contact_miles_driven");
  const durationHours = document.getElementById("case-contact-duration-hours");
  const durationHourDisplay = document.getElementById("casa-contact-duration-hours-display")
  const durationMinutes = document.getElementById("case-contact-duration-minutes");
  const durationMinuteDisplay = document.getElementById("casa-contact-duration-minutes-display")

  milesDriven.onchange = function () {
    const contactMedium = document.getElementById("case_contact_medium_type").value || "(contact medium not set)";
    const contactMediumInPerson = `${contactMedium}` === 'in-person';
    if (milesDriven.value > 0 && !contactMediumInPerson) {
      alert(`Just checking: you drove ${milesDriven.value} miles for a ${contactMedium} contact?`);
    }
  };
  durationHours.onchange = function () {
    if (durationHourDisplay.value !== durationHours.value) {
      durationHourDisplay.value = durationHours.value
    }
    
  }
  durationHourDisplay.onchange, durationHourDisplay.onkeyup = function ()  {
    if (durationHourDisplay.value !== durationHours.value) {
      durationHours.value = durationHourDisplay.value
    }
  }
  durationMinutes.onchange = function () {
    if (durationMinuteDisplay.value !== durationMinutes.value) {
      durationMinuteDisplay.value = durationMinutes.value
    }
    
  }
  durationMinuteDisplay.onchange, durationMinuteDisplay.onkeyup = function ()  {
    if (durationMinuteDisplay.value !== durationMinutes.value) {
      durationMinutes.value = durationMinuteDisplay.value
    }
  }
};
