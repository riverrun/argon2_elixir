defmodule Argon2.ErrorsTest do
  use ExUnit.Case

  alias Argon2.Base

  test "raises error when salt is too short" do
    assert_raise ArgumentError, "Salt is too short", fn ->
      Base.hash_password("password", "notsalt")
    end
  end

  test "raises error when hashlen is too short" do
    assert_raise ArgumentError, "Output is too short", fn ->
      Base.hash_password("password", "somesalt", hashlen: 3)
    end
  end

  test "raises error when password or salt is nil" do
    assert_raise ArgumentError, fn ->
      Base.hash_password(nil, "somesalt")
    end

    assert_raise ArgumentError, fn ->
      Base.hash_password("password", nil)
    end
  end

  test "raises error when using verify_pass" do
    hash = Base.hash_password("", "somesalt")
    invalid_hash = String.replace(hash, "c29tZXNhbHQ", "bm9zYWx0")

    assert_raise ArgumentError, "Salt is too short", fn ->
      Argon2.verify_pass("", invalid_hash)
    end
  end

  test "the NIFs reject arguments outside the supported ranges" do
    assert_raise ArgumentError, fn -> Base.encodedlen_nif(1, 32, 1, 16, 32, 2) end
    assert_raise ArgumentError, fn -> Base.encodedlen_nif(1, 10, 1, 16, 32, 3) end

    assert_raise ArgumentError, fn ->
      Base.hash_nif(1, 10, 1, "pw", "somesalt", 0, 32, 0xFFFFFFFF, 2, 0)
    end
  end

  test "verify_nif rejects a stored hash longer than its buffer" do
    assert_raise ArgumentError, fn ->
      Base.verify_nif(~c"$" ++ List.duplicate(?a, 1023), "pw", 2)
    end
  end

  test "rejects non-ASCII bytes in a stored hash" do
    {password, hash} =
      Enum.find_value(1..100, fn i ->
        password = "password#{i}"
        hash = Base.hash_password(password, "somesaltSOMESALT", t_cost: 1, m_cost: 8)
        if hash |> String.split("$") |> List.last() |> String.contains?("/"), do: {password, hash}
      end)

    tampered = String.replace(hash, "/", <<0x80>>, global: false)

    assert_raise ArgumentError, "Decoding failed", fn ->
      Argon2.verify_pass(password, tampered)
    end
  end

  test "various error messages" do
    assert Base.error_nif(-12) == ~c"Time cost is too small"
    assert Base.error_nif(-21) == ~c"Associated data pointer is NULL, but ad length is not 0"
    assert Base.error_nif(-26) == ~c"There is no such version of Argon2"
    assert Base.error_nif(-36) == ~c"Unknown error code"
  end
end
