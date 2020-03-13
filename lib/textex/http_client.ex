defmodule Textex.HttpClient do
  use HTTPoison.Base

  def get_retrieve_all_groups(override_base_uri \\ nil) do
    get_retrieve_all_groups(override_base_uri, mode())
  end

  def get_retrieve_all_groups(_override_base_uri, :test) do
    get_success_result([
      %{"ContactCount" => 1, "ID" => 482968, "Name" => "Test", "Note" => ""}
    ])
  end

  def get_retrieve_all_groups(override_base_uri, :production) do
    url = groups_uri(override_base_uri)
    response = get!(url)
    processed_get_response(response)
  end

  def post_sms_message!(sms_message, override_base_uri \\ nil) do
    post_sms_message!(sms_message, override_base_uri, mode())
  end

  def post_sms_message!(sms_message, _override_base_uri, :test) do
    case validate_sms_message(sms_message) do
      :ok   -> sms_message_success_result()
      error -> error
    end
  end

  def post_sms_message!(sms_message, override_base_uri, :production) do
    case validate_sms_message(sms_message) do
      :ok   ->
        body = sms_message_body(sms_message)
        response = post!(sends_uri(override_base_uri), body)
        processed_post_sms_message_response(response)
      error -> error
    end
  end

  def sms_message_success_result do
    {:ok, "Message sent"}
  end

  def get_success_result(result) do
    {:ok, result}
  end

  def incorrectly_formatted_phone_number_error_result do
    {:error, "Incorrectly formatted phone number (number must be 10 digits)"}
  end

  def invalid_message_or_subject_error_result do
    {:error, "Invalid message or subject"}
  end

  # PRIVATE ##################################################

  defp validate_sms_message(sms_message) do
    case sms_message.message do
      nil      -> invalid_message_or_subject_error_result()
      _message -> :ok
    end
  end

  defp sends_credentials do
    [user: sends_username(), pass: password()]
  end

  defp get_credentials do
    [User: sends_username(), Password: password()]
  end

  # defp lookups_credentials do
  #   [{:user, lookups_username}, {:pass, password}]
  # end
  #
  defp sends_username do
    Application.get_env(:textex, :sends_username)
  end

  # defp lookups_username do
  #   Application.get_env(:textex, :lookups_username)
  # end
  #
  defp password do
    Application.get_env(:textex, :password)
  end

  defp default_base_uri do
    "https://app.eztexting.com/api"
  end

  defp sends_path do
    "/sending"
  end

  defp groups_path do
    "/groups"
  end

  defp sends_uri(nil) do
    default_base_uri() <> sends_path()
  end
  
  defp sends_uri(override_base_uri) do
    override_base_uri <> sends_path()
  end

  defp groups_uri(override_base_uri) do
    query =  "?" <> URI.encode_query(get_credentials() ++ [format: "json"])
    override_base_uri <> groups_path() <> query
  end

  defp sms_message_body(sms_message) do
    {
      :form, [
        phonenumber: sms_message.phone_number,
        message:     sms_message.message,
      ] ++ sends_credentials()
    }
  end

  defp processed_post_sms_message_response(response) do
    case response.body do
      "1" ->
        sms_message_success_result()
      "-1" ->
        {:error, "Invalid user and/or password or API is not allowed for your account"}
      "-2" ->
        {:error, "Credit limit reached"}
      "-5" ->
        {:error, "Local opt out (the recipient/number is on your opt-out list.)"}
      "-7" ->
        invalid_message_or_subject_error_result()
      "-104" ->
        {:error, "Globally opted out phone number (the phone number has been opted out from all messages sent from our short code)"}
      "-106" ->
        incorrectly_formatted_phone_number_error_result()
      _ ->
        {:error, "Unknown error (please contact our support dept.)"}
    end
  end

  defp processed_get_response(response) do
    case response.body do
      "-1" ->
        {:error, "Invalid user and/or password or API is not allowed for your account"}
      "-2" ->
        {:error, "Credit limit reached"}
      body ->
        get_success_result(body |> Poison.decode! |> get_in(["Response", "Entries"]))
    end
  end

  defp mode do
    Application.get_env(:textex, :mode, :test)
  end
end
