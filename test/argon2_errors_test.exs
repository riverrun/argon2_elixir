defmodule Argon2ErrorsTest do
  use ExUnit.Case

  test "error when salt is too short" do
    assert_raise ArgumentError, "Salt is too short", fn ->
      Argon2.hash_password("password", "notsalt")
    end
  end

  test "error when hashlen is too short" do
    assert_raise ArgumentError, "Output is too short", fn ->
      Argon2.hash_password("password", "somesalt", hashlen: 3)
    end
  end

  test "error when password or salt is nil" do
    assert_raise ArgumentError, "Wrong type - password and salt should be strings", fn ->
      Argon2.hash_password(nil, "somesalt")
    end
    assert_raise ArgumentError, "Wrong type - password and salt should be strings", fn ->
      Argon2.hash_password("password", nil)
    end
    assert_raise ArgumentError, "Wrong type - password should be a string", fn ->
      Argon2.verify_hash('', nil)
    end
  end

  test "various error messages" do
    assert Argon2.Base.error_nif(-12) == 'Time cost is too small'
    assert Argon2.Base.error_nif(-21) == 'Associated data pointer is NULL, but ad length is not 0'
    assert Argon2.Base.error_nif(-26) == 'There is no such version of Argon2'
    assert Argon2.Base.error_nif(-36) == 'Unknown error code'
  end

end
