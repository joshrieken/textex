defmodule Textex.SmsGroupSpec do
  use ESpec

  alias Textex.{HttpClient, SmsGroup}

  describe "Retrieve all" do
    subject do: SmsGroup.retrieve_all()

    let :test_group, do: %{
          "ContactCount" => 1, "ID" => 482968, "Name" => "Test", "Note" => ""
                     }

    let :success_result, do: {:ok, [test_group()]}

    #let :sms_groups do
    #  test_group()
    #end

    it do: should eq(success_result())
  end
end
