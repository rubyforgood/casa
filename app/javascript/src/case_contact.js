window.onload = function () {
  const milesDriven = document.getElementById("case_contact_miles_driven");

  milesDriven.onchange = function () {
    const contactMedium = document.getElementById("case_contact_medium_type").value || "(contact medium not set)";
    const contactMediumInPerson = `${contactMedium}` === 'in-person';
    if (milesDriven.value > 0 && !contactMediumInPerson) {
      alert(`Just checking: you drove ${milesDriven.value} miles for a ${contactMedium} contact?`);
    }
  };
};
