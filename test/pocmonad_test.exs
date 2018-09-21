defmodule PocmonadTest do
  use ExUnit.Case

  test "Ok" do
    assert {:ok, 23} = Pocmonad.Ok.try1()
    assert {:error, :error_n} = Pocmonad.Ok.try2()
  end

  test "MonadEx" do
    assert {:ok, 23} = Pocmonad.MonadEx.try1()
    assert {:error, :error_n} = Pocmonad.MonadEx.try2()
  end

  test "Wormhole" do
    assert {:ok, 23} = Pocmonad.Wormhole.try1()
    assert {:error, {:shutdown, %Protocol.UndefinedError{}}} = Pocmonad.Wormhole.try2()
  end

  test "With" do
    assert {:ok, 23} = Pocmonad.With.try1()
    assert {:error, :error_m} = Pocmonad.With.try2()
  end

  test "Rop" do
    assert {:ok, 23} = Pocmonad.Rop.try1()
    assert {:error, :error_n} = Pocmonad.Rop.try2()
  end

  test "RopMacro" do
    assert {:ok, 23} = Pocmonad.RopMacro.try1()
    assert {:error, :error_n} = Pocmonad.RopMacro.try2()
  end

  test "Opus" do
    assert {:ok, 23} = Pocmonad.Opus.Try1.call(1..9)
    assert {:error, %Opus.PipelineError{error: :error_m}} = Pocmonad.Opus.Try2.call(1..9)
  end

end
