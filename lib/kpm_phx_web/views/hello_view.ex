defmodule KpmPhxWeb.HelloView do
    use KpmPhxWeb, :view
    
    def capitalize(name) do
        String.capitalize(name)
    end

    def render("greeting.json", %{messenger: messenger}) do
        %{ reply: messenger}
    end
end