defmodule Argon2Test do
  use ExUnit.Case
  doctest Argon2

  import Argon2TestHelper
  alias Argon2.Base

  test "only output encoded hash" do
    result = Base.hash_password("password", "somesalt")
    assert is_binary(result)
    assert String.starts_with?(result, "$argon2id$v=19$m=131072,t=8,p=4")
  end

  test "only output raw hash" do
    result = Base.hash_password("password", "somesalt", format: :raw_hash)
    assert is_binary(result)
    refute String.starts_with?(result, "$argon2")
  end

  test "output both raw and encoded hash" do
    {raw, encoded, _} = Base.hash_password("password", "somesalt", format: :report)
    assert is_binary(raw)
    assert is_binary(encoded)
    refute String.starts_with?(raw, "$argon2")
    assert String.starts_with?(encoded, "$argon2id$v=19$m=131072,t=8,p=4")
  end

  test "customizing parameters with config" do
    Application.put_env(:argon2_elixir, :t_cost, 3)
    Application.put_env(:argon2_elixir, :m_cost, 12)
    Application.put_env(:argon2_elixir, :argon2_type, 2)
    result = Base.hash_password("password", "somesalt")
    assert String.starts_with?(result, "$argon2id$v=19$m=4096,t=3,p=4")
    Application.delete_env(:argon2_elixir, :t_cost)
    Application.delete_env(:argon2_elixir, :m_cost)
    Application.delete_env(:argon2_elixir, :argon2_type)
  end

  test "hashing and checking passwords" do
    encoded_hash_check("password")
    encoded_hash_check("hard2guess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    encoded_hash_check("aáåäeéêëoôö")
    encoded_hash_check("aáåä eéêëoôö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    encoded_hash_check("Сколько лет, сколько зим")
    encoded_hash_check("สวัสดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    encoded_hash_check("Я❤três☕ où☔")
  end

  test "user obfuscation function always returns false" do
    assert Argon2.no_user_verify() == false
  end

  test "duration of user obfuscation function is configurable" do
    {short_time, _} = :timer.tc(Argon2, :no_user_verify, [[t_cost: 1, m_cost: 10]])
    {long_time, _} = :timer.tc(Argon2, :no_user_verify, [[t_cost: 3, m_cost: 12]])
    assert long_time > short_time
  end

  test "invalid stored_hash in verify_pass raises" do
    assert_raise ArgumentError, ~r/check the 'stored_hash' input to verify_pass/, fn ->
      Argon2.verify_pass("", "$someinvalidhash")
    end
  end

  test "add hash to map and set password to nil" do
    wrong_list = ["êäöéaoeôáåë", "åáoêëäéôeaö", "aäáeåëéöêôo", ""]
    add_hash_check("aáåäeéêëoôö", wrong_list)
  end

  test "add_hash and check_pass" do
    assert {:ok, user} = Argon2.add_hash("password") |> Argon2.check_pass("password")
    assert {:error, "invalid password"} = Argon2.add_hash("pass") |> Argon2.check_pass("password")
    assert Map.has_key?(user, :password_hash)
  end

  test "add_hash with a custom hash_key and check_pass" do
    assert {:ok, user} =
             Argon2.add_hash("password", hash_key: :encrypted_password)
             |> Argon2.check_pass("password")

    assert {:error, "invalid password"} =
             Argon2.add_hash("pass", hash_key: :encrypted_password)
             |> Argon2.check_pass("password")

    assert Map.has_key?(user, :encrypted_password)
  end

  test "check_pass with custom hash_key" do
    assert {:ok, user} =
             Argon2.add_hash("password", hash_key: :custom_hash)
             |> Argon2.check_pass("password", hash_key: :custom_hash)

    assert Map.has_key?(user, :custom_hash)
  end

  test "check_pass with invalid hash_key" do
    {:error, message} =
      Argon2.add_hash("password", hash_key: :unconventional_name)
      |> Argon2.check_pass("password")

    assert message =~ "no password hash found"
  end

  test "check_pass with password that is not a string" do
    assert {:error, message} = Argon2.add_hash("pass") |> Argon2.check_pass(nil)
    assert message =~ "password is not a string"
  end
end
