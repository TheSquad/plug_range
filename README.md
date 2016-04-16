# Plug-Range

An [Elixir Plug](http://github.com/elixir-lang/plug) to add HTTP Range Requests

## Usage

1. Add this plug to your `mix.exs` dependencies:

```elixir
def deps do
  # ...
  {:plug_range, git: "https://github.com/TheSquad/Plug-Range.git"}
  #...
end
```

When used with phoenix framework, please note that it should be called before Plug.Static
otherwise most assets will be delivered by it before Plug.Range had a chance.

```elixir
defmodule YourApp.Endpoint do
  use Phoenix.Enpoint, otp_app: :your_app

  plug PlugRange

  plug Plug.Static,
  at: "/", from: :my_project, gzip: false,
  only: ~w(css fonts images js favicon.ico robots.txt)

  # ...

  plug YourApp.Router
end
```

## Serving HTTP Range Requests

Modern web browser sometime uses Range Requests to get mostly static files, like images, videos, etc...

For example : when using the ```<video></video>``` tag on your website, not serving HTTP Range Requests
will make Safari fail to retreive the video to play it.

As soon as the request is a "range", the Plug will take over and treat it as such. if not, it will return
the conn like nothing happened.

## RFC 7233

For now PlugRange is not RFC compliant, but I will try to make it compliant as soon as possible.
You are welcome to help in this purpose
