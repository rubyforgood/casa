module TwilioHelper
  def stub_twilio
    twilio_client = instance_double(Twilio::REST::Client)
    messages = instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList)
    allow(Twilio::REST::Client).to receive(:new).with("Aladdin", "open sesame", "articuno34").and_return(twilio_client)
    allow(twilio_client).to receive(:messages).and_return(messages)
    allow(messages).to receive(:list).and_return([])
  end
end
