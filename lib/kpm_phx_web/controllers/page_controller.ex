defmodule KpmPhxWeb.PageController do
  use KpmPhxWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
