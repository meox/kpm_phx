defmodule FakeTicket do
    
    def start_sending(file, callback) do
        File.stream!(file)
        |> Enum.drop(1)
        |> Enum.map(callback)
    end

    def load_mapper(fname) do
        {:ok, data} = File.read(fname)
        data
        |> Poison.decode!()
    end

    def convert(line, mapping) do
        String.split(line, ",", trim: true)
        |> Enum.with_index()
        |> Enum.map(fn {v, index} ->
            convert_it(v, Enum.at(mapping, index) |> Map.get("type"))
        end)
    end

    defp convert_it(value, "number") do
        value
        |> String.trim()
        |> String.to_integer()
    end

    defp convert_it(value, _) do
        value
    end
end