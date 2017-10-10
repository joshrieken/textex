defmodule Textex.SmsMessageSpec do
  use ESpec

  alias Textex.HttpClient
  alias Textex.SmsMessage

  describe "send!" do
    let :success_result,              do: HttpClient.sms_message_success_result()
    let :invalid_phone_number_result, do: HttpClient.invalid_phone_number_result()

    context "when a list of SMS messages is given" do
      context "when the messages are valid" do
        subject do: SmsMessage.send!(sms_messages())

        let :sms_messages do
          [
            %SmsMessage{
              phone_number: "5555555555",
              message:      "Fire in the hole!",
            },
            %SmsMessage{
              phone_number: "5555555555",
              message:      "I've got you in my sights.",
            },
          ]
        end

        let :success_results do
          [
            success_result(),
            success_result(),
          ]
        end

        it do: should eq(success_results())
      end
    end

    context "when one SMS message is given" do
      subject do: SmsMessage.send!(sms_message())

      context "when the message is valid" do
        let :sms_message do
          %SmsMessage{
            phone_number: "5555555555",
            message:      "Fire in the hole!",
          }
        end

        it do: should eq(success_result())
      end
    end
  end
end
