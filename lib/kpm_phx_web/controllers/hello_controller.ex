defmodule KpmPhxWeb.HelloController do
    use KpmPhxWeb, :controller

    def index(conn, _params) do
        render conn, "index.html"
    end

    def show(conn, %{"messenger" => messenger}) do
        render conn, "show.html", messenger: messenger
    end

    def greeting(conn, %{"messenger" => messenger}) do
        render conn, "greeting.json", messenger: messenger
    end
end