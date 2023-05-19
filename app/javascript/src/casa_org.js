//class="collapse" aria-labelledby="headingOne" data-bs-parent="#accordionTwilio"

const TWILIO_PHONE_NUMBER = "#casa_org_twilio_phone_number"

function hello(){
    console.log("hello")
    if ($('.accordionTwilio').is(":checked")) {
        console.log("checked")
        $("#casa_org_twilio_phone_number").attr("required", true)
        $("#casa_org_twilio_phone_number").removeAttr("disabled")
        $("#casa_org_twilio_account_sid").attr("required", true)
        $("#casa_org_twilio_account_sid").removeAttr("disabled")
        $("#casa_org_twilio_api_key_sid").attr("required", true)
        $("#casa_org_twilio_api_key_sid").removeAttr("disabled")
        $("#casa_org_twilio_api_key_secret").attr("required", true)
        $("#casa_org_twilio_api_key_secret").removeAttr("disabled")
    }else{
        console.log("unchecked")
        $("#casa_org_twilio_phone_number").removeAttr("required", false)
        $("#casa_org_twilio_phone_number").attr("disabled", true)
        $("#casa_org_twilio_account_sid").removeAttr("required", false)
        $("#casa_org_twilio_account_sid").attr("disabled", true)
        $("#casa_org_twilio_api_key_sid").removeAttr("required", false)
        $("#casa_org_twilio_api_key_sid").attr("disabled", true)
        $("#casa_org_twilio_api_key_secret").removeAttr("required", false)
        $("#casa_org_twilio_api_key_secret").attr("disabled", true)
    }
}
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
    }
    ($('.accordionTwilio').on('click', hello))



})