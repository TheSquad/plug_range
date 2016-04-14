defmodule PlugRangeTest do
  use ExUnit.Case
  use Plug.Test
  doctest PlugRange

  test "the truth" do
    assert 1 + 1 == 2
  end

  @opts PlugRange.init([])

  test "no range request" do
    conn = conn(:get, "/lorem.txt")
    conn_changed? = PlugRange.call(conn, @opts)
    assert conn == conn_changed?
  end

  test "range request 0-" do
    conn = conn(:get, "/lorem.txt")
    |> Plug.Conn.put_req_header("range", "bytes=0-")

    conn_changed? = PlugRange.call(conn, @opts)
    assert conn == conn_changed?
  end

  test "range request 0-32" do
    conn = conn(:get, "/lorem.txt")
    |> Plug.Conn.put_req_header("range", "bytes=0-32")

    conn = PlugRange.call conn, @opts

    assert conn.state == :sent
    assert conn.status == 206
    res_string = File.stream!("priv/static/lorem.txt", [], 33) |> Stream.take(1) |> Enum.to_list |> to_string
    assert conn.resp_body == res_string
  end

  test "range request -32" do
    conn = conn(:get, "/lorem.txt")
    |> Plug.Conn.put_req_header("range", "bytes=-32")

    conn = PlugRange.call conn, @opts

    assert conn.state == :sent
    assert conn.status == 206
    fs = File.stat! "priv/static/lorem.txt"
    res_string = File.read!("priv/static/lorem.txt") |> String.slice(fs.size - 32, 32)

    assert conn.resp_body == res_string
  end

  test "bad range request" do
    conn = conn(:get, "/lorem.txt")
    |> Plug.Conn.put_req_header("range", "bytes=-")

    conn = PlugRange.call conn, @opts
    assert conn.state == :sent
    assert conn.status == 416
  end

  test "bad range request 2" do
    conn = conn(:get, "/lorem.txt")
    |> Plug.Conn.put_req_header("range", "bytes=toto")

    conn = PlugRange.call conn, @opts
    assert conn.state == :sent
    assert conn.status == 416
  end

  test "bad range request 3" do
    conn = conn(:get, "/lorem.txt")
    |> Plug.Conn.put_req_header("range", "by")

    conn = PlugRange.call conn, @opts
    assert conn.state == :sent
    assert conn.status == 416
  end

end
