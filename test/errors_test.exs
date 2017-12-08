defmodule Argon2.ErrorsTest do
  use ExUnit.Case

  alias Argon2.Base

  test "error when salt is too short" do
    assert_raise ArgumentError, "Salt is too short", fn ->
      Base.hash_password("password", "notsalt")
    end
  end

  test "error when hashlen is too short" do
    assert_raise ArgumentError, "Output is too short", fn ->
      Base.hash_password("password", "somesalt", hashlen: 3)
    end
  end

  test "error when password or salt is nil" do
    assert_raise ArgumentError, fn ->
      Base.hash_password(nil, "somesalt")
    end

    assert_raise ArgumentError, fn ->
      Base.hash_password("password", nil)
    end
  end

  test "various error messages" do
    assert Base.error_nif(-12) == 'Time cost is too small'
    assert Base.error_nif(-21) == 'Associated data pointer is NULL, but ad length is not 0'
    assert Base.error_nif(-26) == 'There is no such version of Argon2'
    assert Base.error_nif(-36) == 'Unknown error code'
  end
end
