defmodule Shh.Result do
  defstruct exit_status: 0, data: [], errors: []

  defimpl Collectable do
    def into(result) do
      {result,
       fn
         acc, {:cont, {:normal, data}} ->
           update_in(acc.data, &[data | &1])

         acc, {:cont, {:error, data}} ->
           update_in(acc.errors, &[data | &1])

         acc, {:cont, {:exit_status, code}} ->
           %{acc | exit_status: code}

         acc, :done ->
           acc = update_in(acc.data, &Enum.reverse/1)
           update_in(acc.errors, &Enum.reverse/1)

         _acc, :halt ->
           :ok
       end}
    end
  end
end
