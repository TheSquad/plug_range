defmodule PlugRange do
  @behaviour Plug
  @allowed_methods ~w(GET HEAD)
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    if (Enum.empty?(Plug.Conn.get_req_header(conn, "range"))) do
      conn
    else
      file_path = "priv/static" <> conn.request_path
      if File.exists? file_path do

        stats = File.stat! file_path
        filesize = stats.size

        req = Regex.run(~r/bytes=([0-9]+)-([0-9]+)?/, conn |> Plug.Conn.get_req_header("range") |> List.first)

        {req_start, _} = req |> Enum.at(1) |> Integer.parse
        {req_end, _} = req |> Enum.at(2, filesize |> to_string) |> Integer.parse


        IO.puts "req_end : #{req_end} // filesize = #{filesize}"

        if (req_start == 0 && req_end == filesize) do

          conn
        else

          file_end = ( filesize - 2) |> to_string

          length = req_end - req_start + 1

          conn
          |> Plug.Conn.put_resp_header("Accept-Ranges", "bytes")
          |> Plug.Conn.put_resp_header("Content-Range", "bytes #{req_start}-#{req_end}/#{filesize}")
          |> Plug.Conn.send_file(206, file_path, req_start, length)
          |> Plug.Conn.halt
        end
      else
        conn
      end
    end
  end
end
