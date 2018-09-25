defmodule Lib do
  def filter(list) do
    Enum.filter(list, fn x -> rem(x, 3) == 0 || rem(x, 5) == 0 end)
  end
  def reduce(list) do
    Enum.reduce(list, 0, fn (acc, x) -> acc + x end)
  end
  def filter_error(_list) do
    :error_n
  end
end
defmodule LibTT do
  def filter(list), do: {:ok, Lib.filter(list)}
  def reduce(list), do: {:ok, Lib.reduce(list)}
  def filter_error(list), do: {:error, Lib.filter_error(list)}
end
defmodule LibForRop do
  def filter({:ok, list}), do: Lib.filter(list)
  def reduce({:ok, list}), do: Lib.reduce(list)
  def filter_error({:ok, list}), do: Lib.filter_error(list)
end
defmodule LibForRopTT do
  def filter({:ok, list}), do: LibTT.filter(list)
  def filter({:error, reason}), do: {:error, reason}

  def reduce({:ok, list}), do: LibTT.reduce(list)
  def reduce({:error, reason}), do: {:error, reason}

  def filter_error({:ok, list}), do: LibTT.filter_error(list)
  def filter_error({:error, reason}), do: {:error, reason}
end

defmodule Pocmonad.Ok do
  @moduledoc """
  This is the [OK](https://github.com/CrowdHailer/OK) module,
  Elegant error/exception handling in Elixir, with result monads.


  HEX
  ```
  {:ok, "~> 2.0"}
  ```
  ** Pros **:
  - Easy to implement
  - Popular solution

  ** Cons **:
  - Implementation given for other people
  - Strange simbol `~>>`

  """
  use OK.Pipe
  @doc """
  - input `{:ok, any}` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.Ok.try1()
  {:ok, 23}
  ```
  """
  def try1() do
    {:ok, 1..9}
      ~>> LibTT.filter
      ~>> LibTT.reduce
  end
  @doc """
  - input `{:ok, any}` call returns `{:error, Reason}`.

  ## Examples
  ```
  iex> Pocmonad.Ok.try2()
  {:error, :error_n}
  ```
  """
  def try2() do
    {:ok, 1..9}
      ~>> LibTT.filter_error
      ~>> LibTT.reduce
  end
end

defmodule Pocmonad.MonadEx do
  import Monad.Result
  use Monad.Operators

  def try1() do
    1..9
      |> return
      ~>> fn args -> from_tuple LibTT.filter(args) end
      ~>> fn args -> from_tuple LibTT.reduce(args) end
      |> to_tuple
  end
  def try2() do
    1..9
      |> return
      ~>> fn args -> from_tuple LibTT.filter_error(args) end
      ~>> fn args -> from_tuple LibTT.reduce(args) end
      |> to_tuple
  end
end

defmodule Pocmonad.Wormhole do
  def try1() do
    {:ok, 1..9}
      |> (fn args -> Wormhole.capture(LibForRop, :filter, [args]) end).()
      |> (fn args -> Wormhole.capture(LibForRop, :reduce, [args]) end).()
  end
  def try2() do
    {:ok, 1..9}
      |> (fn args -> Wormhole.capture(LibForRop, :filter_error, [args]) end).()
      |> (fn args -> Wormhole.capture(LibForRop, :reduce, [args]) end).()
  end
end

defmodule Pocmonad.With do
  def try1() do
    with {:ok, list} <- LibTT.filter(1..9),
         {:ok, reduced} <- LibTT.reduce(list), do: {:ok, reduced}
  end
  def try2() do
    with {:ok, list} <- LibTT.filter_error(1..9),
         {:ok, reduced} <- LibTT.reduce(list) do
      {:ok, reduced}
    else
      {:error, :error_n} -> {:error, :error_m}
    end
  end
end

defmodule Pocmonad.Rop do
  def try1() do
    {:ok, 1..9}
      |> LibForRopTT.filter
      |> LibForRopTT.reduce
  end
  def try2() do
    {:ok, 1..9}
      |> LibForRopTT.filter_error
      |> LibForRopTT.reduce
  end
end

defmodule Pocmonad.Macro do
  defmacro left ~>> right do
    quote do
      case unquote(left) do
        {:ok, x} -> x |> unquote(right)
        {:error, _} = term -> term
      end
    end
  end
end
defmodule Pocmonad.RopMacro do
  import Pocmonad.Macro

  def try1() do
    {:ok, 1..9}
      ~>> LibTT.filter
      ~>> LibTT.reduce
  end
  def try2() do
    {:ok, 1..9}
      ~>> LibTT.filter_error
      ~>> LibTT.reduce
  end
end

defmodule Pocmonad.Opus do
  defmodule Try1 do
    use Opus.Pipeline

    step  :filter, with: &Lib.filter/1
    step  :reduce, with: &Lib.reduce/1
  end
  defmodule Try2 do
    use Opus.Pipeline

    step  :filter, with: &Lib.filter_error/1
    step  :reduce, with: &Lib.reduce/1, error_message: :error_m
  end

end

defmodule Pocmonad.Happy do
  import Happy

  def try1() do
    happy_path do
      {:ok, list} = LibTT.filter(1..9)
      {:ok, reduced} = LibTT.reduce(list)
      {:ok, reduced}
    end
  end
  def try2() do
    happy_path do
      {:ok, list} = LibTT.filter_error(1..9)
      {:ok, reduced} = LibTT.reduce(list)
      {:ok, reduced}
    end
  end
end
