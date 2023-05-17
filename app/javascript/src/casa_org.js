//class="collapse" aria-labelledby="headingOne" data-bs-parent="#accordionTwilio"
$('document').ready(() => {
    //class='enable_twilio' class='form-check-input' data - bs - toggle="collapse" data - bs - target="#collapseTwilio" aria - expanded="true"
    //$('.accordionTwilio').addClass("enable_twilio")
    $('.accordionTwilio').attr('data-bs-toggle', "collapse")
    $('.accordionTwilio').attr('data-bs-target', "#collapseTwilio")
    $('.accordionTwilio').attr('aria-expanded', "true")
    console.log("Accordion Twilio", $('.accordionTwilio').val())
    if ($('.accordionTwilio').is(":checked")){
        console.log("Check please")
        //$('.accordionTwilio').val('1')
        $('.accordionTwilio').removeAttr('aria_expanded')
        $('.accordionTwilio').removeClass('collapsed')
        $('#collapseTwilio').addClass('show')
        //$('#accordionTwilio').removeClass('collapse')
        //$('#accordionTwilio').addClass('show')
    }else{
        //$('#accordionTwilio').val('0')
        //$('#accordionTwilio').addClass('collapsed')
    }
})