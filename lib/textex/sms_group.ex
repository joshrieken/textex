defmodule Textex.SmsGroup do

  alias Textex.HttpClient

  def retrieve_all() do
    HttpClient.get_retrieve_all_groups(base_sends_uri())
  end

  def base_sends_uri do
    Application.get_env(:textex, :base_sends_uri)
  end

end
