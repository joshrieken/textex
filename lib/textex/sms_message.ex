defmodule Textex.SmsMessage do
  alias Textex.HttpClient

  defstruct phone_number: nil, message: nil

  def send!(sms_messages) when is_list(sms_messages) do
    Enum.map(sms_messages, &send!(&1))
  end

  def send!(sms_message) do
    HttpClient.post_sms_message!(sms_message, base_sends_uri())
  end

  def base_sends_uri do
    Application.get_env(:textex, :base_sends_uri)
  end
end
