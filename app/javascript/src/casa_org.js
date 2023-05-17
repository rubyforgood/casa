//class="collapse" aria-labelledby="headingOne" data-bs-parent="#accordionTwilio"
$('document').ready(() => {
    if ($('#casa_org_twilio_enabled').is(":checked")){
        console.log("Check please")
        $('#accordionTwilio').removeAttr('aria_expanded')
        $('#accordionTwilio').removeClass('collapsed')
        $('#collapseTwilio').addClass('show')
        //$('#accordionTwilio').removeClass('collapse')
        //$('#accordionTwilio').addClass('show')
    }else{
        //$('#accordionTwilio').addClass('collapsed')
    }
})