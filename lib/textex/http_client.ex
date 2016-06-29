defmodule Textex.HttpClient do
  use HTTPoison.Base

  def post_sms_message!(sms_message, override_base_uri \\ nil) do
    post_sms_message!(sms_message, override_base_uri, mode())
  end
  def post_sms_message!(_sms_message, _override_base_uri, :test) do
    sms_message_success_result
  end
  def post_sms_message!(sms_message, override_base_uri, :production) do
    body = sms_message_body(sms_message)
    response = post!(sends_uri(override_base_uri), body)
    processed_post_sms_message_response(response)
  end

  def sends_credentials do
    [user: sends_username, pass: password]
  end

  def lookups_credentials do
    [{:user, lookups_username}, {:pass, password}]
  end

  def sends_username do
    Application.get_env(:textex, :sends_username)
  end

  def lookups_username do
    Application.get_env(:textex, :lookups_username)
  end

  def password do
    Application.get_env(:textex, :password)
  end

  def default_base_uri do
    "https://app.eztexting.com/api"
  end

  def sends_path do
    "/sending"
  end

  def sends_uri(nil) do
    default_base_uri <> sends_path
  end
  def sends_uri(override_base_uri) do
    override_base_uri <> sends_path
  end

  def sms_message_body(sms_message) do
    {
      :form, [
        phonenumber: sms_message.phone_number,
        message:     sms_message.message,
      ] ++ sends_credentials
    }
  end

  def processed_post_sms_message_response(response) do
    case response.body do
      "1" ->
        sms_message_success_result
      "-1" ->
        {:error, "Invalid user and/or password or API is not allowed for your account"}
      "-2" ->
        {:error, "Credit limit reached"}
      "-5" ->
        {:error, "Local opt out (the recipient/number is on your opt-out list.)"}
      "-7" ->
        {:error, "Invalid message or subject"}
      "-104" ->
        {:error, "Globally opted out phone number (the phone number has been opted out from all messages sent from our short code)"}
      "-106" ->
        {:error, "Incorrectly formatted phone number (number must be 10 digits)"}
      _ ->
        {:error, "Unknown error (please contact our support dept.)"}
    end
  end

  def sms_message_success_result do
    {:ok, "Message sent"}
  end

  def mode do
    Application.get_env(:textex, :mode, :test)
  end
end
