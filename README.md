# Textex

Elixir wrapper for the [EZ Texting](http://www.eztexting.com/developers) SMS API.

## Installation

The package can be installed as:

  1. Add `textex` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:textex, "~> 0.2.2"}]
    end
    ```

  2. Ensure `textex` is started before your application:

    ```elixir
    def application do
      [applications: [:textex]]
    end
    ```

## Usage

### Configuration

Put the following in `config/config.exs` or the appropriate environment config file:

```elixir
config :textex,
  sends_username: "replace_me",
  password: "and_me_too!",
  base_sends_uri: "https://app.grouptexting.com/api", # optional; uses the eztexting API url by default
  mode: :production # optional; specifying :test will not make any actual API calls
```

### Sending a single SMS message

```elixir
sms_message = %Textex.SmsMessage{
  phone_number: "5555555555", # must be 10 digits
  message:      "Fire in the hole!",
},

Textex.SmsMessage.send!(sms_message)
# => {:ok, "Message sent"}
```

### Sending multiple SMS messages
```elixir
sms_messages = [
  %Textex.SmsMessage{
    phone_number: "5555555555", # must be 10 digits
    message:      "Fire in the hole!",
  },
  %Textex.SmsMessage{
    phone_number: "5555555555", # must be 10 digits
    message:      "I've got you in my sights.",
  },
]

Textex.SmsMessage.send!(sms_messages)
# => [{:ok, "Message sent"}, {:ok, "Message sent"}]
```

### Getting the complete list of groups
```elixir
Textex.SmsGroups.retrieve_all()
# => {:ok, [
      %{"ContactCount" => 1, 
      "ID" => 12345, 
      "Name" => "Test", 
      "Note" => "Test Users"}
    ]
}

```
## TODO

- [X] Support sending single and multiple SMS messages
- [ ] Full support for the sending API
- [ ] Support checking credit count
- [ ] Support checking whether a keyword is available
- [ ] Support voice broadcast
