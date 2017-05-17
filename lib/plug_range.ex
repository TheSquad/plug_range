defmodule PlugRange do
  @behaviour Plug
  # @allowed_methods ~w(GET HEAD)

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

        req = Regex.run(~r/bytes=([0-9]+)?-([0-9]+)?/, conn |> Plug.Conn.get_req_header("range") |> List.first)

        case req do
          p when p == nil or ["bytes=", "", "-"] == p or length(p) < 2 ->
            send_bad_range conn
          _ ->
            {req_start, _} =
            if (req |> Enum.at(1) == "") do
              {-1, :end_file}
            else
              req |> Enum.at(1)  |> Integer.parse
            end
            {req_end, _} = req |> Enum.at(2, filesize |> to_string) |> Integer.parse

            if (req_start == 0 && req_end == filesize) do
              conn
            else

              {req_start, length} = case req_start do
                                      -1 -> {filesize - req_end, req_end}
                                      _ -> {req_start, req_end - req_start + 1}
                                    end

              # file_end = ( filesize - 2) |> to_string

              conn
              |> Plug.Conn.put_resp_header("accept-ranges", "bytes")
              |> Plug.Conn.put_resp_header("content-range", "bytes #{req_start}-#{req_end}/#{filesize}")
              |> Plug.Conn.send_file(206, file_path, req_start, length)
              |> Plug.Conn.halt
            end
        end
      end
    end
  end

  def send_bad_range(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.put_resp_header("content-length", bad_range() |> String.length |> to_string)
    |> Plug.Conn.send_resp(416, bad_range())
    |> Plug.Conn.halt
  end

  def bad_range do
    """
    <html>
    <head><title>416 Requested Range Not Satisfiable</title></head>
    <body bgcolor="white">
    <center><h1>416 Requested Range Not Satisfiable</h1></center>
    <hr><center>cowboy</center>
    </body>
    </html>
    """
  end
end
