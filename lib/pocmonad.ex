defmodule Lib do
  @moduledoc false
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
  @moduledoc false
  def filter(list), do: {:ok, Lib.filter(list)}
  def reduce(list), do: {:ok, Lib.reduce(list)}
  def filter_error(list), do: {:error, Lib.filter_error(list)}
end
defmodule LibForRop do
  @moduledoc false
  def filter({:ok, list}), do: Lib.filter(list)
  def reduce({:ok, list}), do: Lib.reduce(list)
  def filter_error({:ok, list}), do: Lib.filter_error(list)
end
defmodule LibForRopTT do
  @moduledoc false
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
  @moduledoc """
  This is the [MonadEx](https://github.com/rob-brown/MonadEx) module,
  MonadEx introduces monads into Elixir. Monads encapsulate state and control the flow of code. A monad's bind operation is similar, but more powerful, than Elixir's built-in pipelines.

  HEX
  ```
  {:monadex, "~> 1.1"}
  ```
  ** Pros **:
  - There is more then only tagged tuple flow
  - maybe is other great way to avoid nullable issues
  - Popular solution

  ** Cons **:
  - Implementation given for other people
  - Strange simbol `~>>`
  - big boilerplate
  - to much transformation

  """
  import Monad.Result
  use Monad.Operators

  @doc """
  - input `any` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.MonadEx.try1()
  {:ok, 23}
  ```
  """
  def try1() do
    1..9
      |> return
      ~>> fn args -> from_tuple LibTT.filter(args) end
      ~>> fn args -> from_tuple LibTT.reduce(args) end
      |> to_tuple
  end
  @doc """
  - input `any` call returns `{:error, Reason}`.

  ## Examples
  ```
  iex> Pocmonad.MonadEx.try2()
  {:error, :error_n}
  ```
  """
  def try2() do
    1..9
      |> return
      ~>> fn args -> from_tuple LibTT.filter_error(args) end
      ~>> fn args -> from_tuple LibTT.reduce(args) end
      |> to_tuple
  end
end

defmodule Pocmonad.Wormhole do
  @moduledoc """
  This is the [Wormhole](https://github.com/renderedtext/wormhole) module,
  Wormhole captures anything that is emitted out of the callback (return value or error reason) and transfers it to the calling process in the form {:ok, state} or {:error, reason}.


  HEX
  ```
  {:wormhole, "~> 2.2"}
  ```
  ** Pros **:
  - create a net to capture any kind of error
  - its optimized to concurrency
  - timeouts
  - retrys count
  - backoff or abort with timeout

  ** Cons **:
  - Implementation given for other people
  - big boilerplate
  - to much transformation
  - must be wrap with anon function
  - pollution on logs
  - Error Reason is opiniative
  """

  @doc """
  - input `{:ok, any}` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.Wormhole.try1()
  {:ok, 23}
  ```
  """
  def try1() do
    {:ok, 1..9}
      |> (fn args -> Wormhole.capture(LibForRop, :filter, [args]) end).()
      |> (fn args -> Wormhole.capture(LibForRop, :reduce, [args]) end).()
  end
  @doc """
  - input `{:ok, any}` call returns `{:error, Reason}`.

  ## Examples
  ```
  iex> Pocmonad.Wormhole.try2()
  {:error, {:shutdown, %Protocol.UndefinedError{
               description: "",
               protocol: Enumerable,
               value: :error_n
             }}}
  ```
  """
  def try2() do
    {:ok, 1..9}
      |> (fn args -> Wormhole.capture(LibForRop, :filter_error, [args]) end).()
      |> (fn args -> Wormhole.capture(LibForRop, :reduce, [args]) end).()
  end
end

defmodule Pocmonad.With do
  @moduledoc """
  This is the With module,
  As we are now able to parse commands, we can finally start implementing the logic that runs the commands. Let’s add a stub definition for this function for now.

  ** Pros **:
  - Pure Elixir implementation
  - Catch and treat errors inside the block

  ** Cons **:
  - Not follow the pipeline way
  - Can be complex to read
  - Not able to work with Streams
  """

  @doc """
  - input `any` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.With.try1()
  {:ok, 23}
  ```
  """
  def try1() do
    with {:ok, list} <- LibTT.filter(1..9),
         {:ok, reduced} <- LibTT.reduce(list), do: {:ok, reduced}
  end
  @doc """
  - input `any` call returns `{:error, Reason}`.

  ## Examples
  ```
  iex> Pocmonad.With.try2()
  {:error, :error_m}
  ```
  """
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
  @moduledoc """
  This is the [Rop](https://zohaib.me/railway-programming-pattern-in-elixir/) module,
  The Elixir Pipeline with potatoes.

  ** Pros **:
  - Pure Elixir implementation
  - Catch and treat errors inside the block
  - Pipeline Elixir Way
  - Follow ideas behind Erlang
  - Easy to read

  ** Cons **:
  - Must always implement the error side of all methods
  """

  @doc """
  - input `{:ok, any}` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.Rop.try1()
  {:ok, 23}
  ```
  """
  def try1() do
    {:ok, 1..9}
      |> LibForRopTT.filter
      |> LibForRopTT.reduce
  end
  @doc """
  - input `{:ok, any}` call returns `{:error, Reason}`.

  ## Examples
  ```
  iex> Pocmonad.Rop.try2()
  {:error, :error_n}
  ```
  """
  def try2() do
    {:ok, 1..9}
      |> LibForRopTT.filter_error
      |> LibForRopTT.reduce
  end
end

defmodule Pocmonad.Macro do
  @moduledoc false
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
  @moduledoc """
  This is the [RopMacro](https://zohaib.me/railway-programming-pattern-in-elixir/) module,
  The Elixir Pipeline with potatoes and macros.

  ** Pros **:
  - Pure Elixir implementation
  - Catch and treat errors inside the block
  - Pipeline Elixir Way
  - Follow ideas behind Erlang
  - Easy to read
  - Dont need to implement the error side of all methods

  ** Cons **:
  - Home made solution
  - Must mantain the macros
  - Strange simbol `~>>`
  """
  import Pocmonad.Macro
  @doc """
  - input `{:ok, any}` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.RopMacro.try1()
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
  iex> Pocmonad.RopMacro.try2()
  {:error, :error_n}
  ```
  """
  def try2() do
    {:ok, 1..9}
      ~>> LibTT.filter_error
      ~>> LibTT.reduce
  end
end

defmodule Pocmonad.Opus do
  @moduledoc """
  This is the [Opus](https://github.com/Zorbash/opus) module,
  A framework for pluggable business logic components

  HEX
  ```
  {:opus, "~> 0.5.1"}
  ```
  ** Pros **:
  - Each Opus pipeline module has a single entry point and returns tagged tuples {:ok, value} | {:error, error}
  - A pipeline is a composition of stateless stages
  - A stage returning {:error, _} halts the pipeline
  - A stage may be skipped based on a condition function (:if option)
  - Exceptions are converted to {:error, error} tuples by default
  - An exception may be left to raise using the :raise option
  - Each stage of the pipeline is instrumented. Metrics are captured automatically (but can be disabled).
  - Errors are meaningful and predictable.

  ** Cons **:
  - Very oppinied
  - Create a mess on documentation
  - Dont follow the pipeline way
  - necessary hack to work properly
  - its not a lib, its a framework have the own way
  """
  defmodule Try1 do
    use Opus.Pipeline
    @moduledoc """
    - input `{:ok, any}` call returns `{:ok, any}`;

    ## Examples
    ```
    iex> Pocmonad.Opus.try(1..9)
    {:ok, 23}
    ```
    """
    step  :filter, with: &Lib.filter/1
    step  :reduce, with: &Lib.reduce/1
  end
  defmodule Try2 do
    use Opus.Pipeline
    @moduledoc """
    - input `{:ok, any}` call returns `{:error, Reason}`.

    ## Examples
    ```
    iex> Pocmonad.Opus.try2(1..9)
    {:error, :error_n}
    ```
    """
    step  :filter, with: &Lib.filter_error/1
    step  :reduce, with: &Lib.reduce/1, error_message: :error_m
  end

end

defmodule Pocmonad.Happy do
  @moduledoc """
  This is the [Happy](https://github.com/vic/happy) module,
  Ok, so I was just trying to find a nice way (beautiful syntax, yet flexible enough) to handle errors in elixir. Handling :ok/:error like tuples without lots of if/cases.

  HEX
  ```
  {:happy, "~> 1.3"}
  ```
  ** Pros **:
  - Clean to read
  - Its kind of with but less oppinied

  ** Cons **:
  - Implementation given for other people
  - Not follow the pipeline way
  - sounds like framework and not lib
  """
  import Happy
  @doc """
  - input `{:ok, any}` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.Happy.try1()
  {:ok, 23}
  ```
  """
  def try1() do
    happy_path do
      {:ok, list} = LibTT.filter(1..9)
      {:ok, reduced} = LibTT.reduce(list)
      {:ok, reduced}
    end
  end
  @doc """
  - input `{:ok, any}` call returns `{:ok, any}`;

  ## Examples
  ```
  iex> Pocmonad.Happy.try1()
  {:ok, 23}
  ```
  """
  def try2() do
    happy_path do
      {:ok, list} = LibTT.filter_error(1..9)
      {:ok, reduced} = LibTT.reduce(list)
      {:ok, reduced}
    end
  end
end
