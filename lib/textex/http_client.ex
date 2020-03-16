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
    {:error, :forbidden, ["PhoneNumbers: Please enter a valid phone number."]}
  end

  def insufficient_credits_error_result do
    {:error, :forbidden, ["You currently do not have sufficient credits to send this campaign. Please purchase at least 1 credit(s) to send out this message."]}
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
    [User: sends_username(), Password: password()]
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
    "/sending/messages"
  end

  defp groups_path do
    "/groups"
  end

  defp sends_uri(nil) do
    default_base_uri() <> sends_path()
  end
 
  defp sends_uri(override_base_uri) do
    query =  "?" <> URI.encode_query([format: "json"])
    override_base_uri <> sends_path() <> query
  end

  defp groups_uri(override_base_uri) do
    query =  "?" <> URI.encode_query(get_credentials() ++ [format: "json"])
    override_base_uri <> groups_path() <> query
  end

  defp sms_message_body(sms_message) do
    form = [
      Message:     sms_message.message,
    ] ++ sends_credentials() 

    form = if sms_message.groups do
      form ++ [Groups: sms_message.groups]
    else
      form
    end

    form = if sms_message.phone_number do
      form ++ [PhoneNumbers: [sms_message.phone_number]]
    else
      form
    end

    {:form, form}
  end

  defp processed_post_sms_message_response(response) do
    with code <- response.body |> Poison.decode! |> get_in(["Response","Code"]),
         errors <- response.body |> Poison.decode! |> get_in(["Response", "Errors"]) do
      case code do
        201 ->
          sms_message_success_result()
        401 ->
          {:error, :unauthorized, errors}
        403 ->
          {:error, :forbidden, errors}
        500 ->
          {:error, :unkown, errors}
        _ ->
          {:error, "Unexpected error (please contact our support dept.)"}
      end
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
