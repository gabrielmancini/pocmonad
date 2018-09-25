defmodule PocmonadTest do
  use ExUnit.Case

  doctest Pocmonad.Ok
  test "Ok" do
    assert {:ok, 23} = Pocmonad.Ok.try1()
    assert {:error, :error_n} = Pocmonad.Ok.try2()
  end

  doctest Pocmonad.MonadEx
  test "MonadEx" do
    assert {:ok, 23} = Pocmonad.MonadEx.try1()
    assert {:error, :error_n} = Pocmonad.MonadEx.try2()
  end

  doctest Pocmonad.Wormhole
  test "Wormhole" do
    assert {:ok, 23} = Pocmonad.Wormhole.try1()
    assert {:error, {:shutdown, %Protocol.UndefinedError{}}} = Pocmonad.Wormhole.try2()
  end

  doctest Pocmonad.With
  test "With" do
    assert {:ok, 23} = Pocmonad.With.try1()
    assert {:error, :error_m} = Pocmonad.With.try2()
  end

  doctest Pocmonad.Rop
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

  test "Happy" do
    assert {:ok, 23} = Pocmonad.Happy.try1()
    assert {:error, :error_n} = Pocmonad.Happy.try2()
  end

end
