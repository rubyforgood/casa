window.onload = function() {
  var milesInput = document.getElementById("case_contact_miles_driven");
  milesInput.onchange = function(){
    if(milesInput.value > 0){
      alert('Are you sure?');
    }
  };
};
