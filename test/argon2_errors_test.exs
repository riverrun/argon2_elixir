defmodule Argon2.ErrorsTest do
  use ExUnit.Case

  test "raise error when salt is too short" do
    assert_raise ArgumentError, "Salt is too short", fn ->
      Argon2.hash_password("password", "notsalt")
    end
  end

  test "raise error when hashlen is too short" do
    assert_raise ArgumentError, "Output is too short", fn ->
      Argon2.hash_password("password", "somesalt", hashlen: 3)
    end
  end

  test "various error codes and messages" do
    assert_raise ArgumentError, "Output pointer is NULL", fn ->
      Argon2.Errors.handle_error(-1)
    end
    assert_raise ArgumentError, "Memory cost is too large", fn ->
      Argon2.Errors.handle_error(-15)
    end
    assert_raise ArgumentError, "There is no such version of Argon2", fn ->
      Argon2.Errors.handle_error(-26)
    end
  end

end
