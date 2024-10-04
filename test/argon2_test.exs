defmodule Argon2Test do
  use ExUnit.Case
  doctest Argon2

  import Comeonin.BehaviourTestHelper

  alias Argon2.Base

  test "implementation of Comeonin.PasswordHash behaviour" do
    password = Enum.random(ascii_passwords())
    assert correct_password_true(Argon2, password)
    assert wrong_password_false(Argon2, password)
  end

  test "Comeonin.PasswordHash behaviour with non-ascii characters" do
    password = Enum.random(non_ascii_passwords())
    assert correct_password_true(Argon2, password)
    assert wrong_password_false(Argon2, password)
  end

  test "only output encoded hash" do
    result = Base.hash_password("password", "somesalt")
    assert is_binary(result)
    assert String.starts_with?(result, "$argon2id$v=19$m=65536,t=3,p=4")
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
    assert String.starts_with?(encoded, "$argon2id$v=19$m=65536,t=3,p=4")
  end

  test "customizing parameters with config" do
    Application.put_env(:argon2_elixir, :t_cost, 2)
    Application.put_env(:argon2_elixir, :m_cost, 12)
    Application.put_env(:argon2_elixir, :parallelism, 2)
    Application.put_env(:argon2_elixir, :argon2_type, 2)
    result = Base.hash_password("password", "somesalt")
    assert String.starts_with?(result, "$argon2id$v=19$m=4096,t=2,p=2")
    Application.delete_env(:argon2_elixir, :t_cost)
    Application.delete_env(:argon2_elixir, :m_cost)
    Application.delete_env(:argon2_elixir, :parallelism)
    Application.delete_env(:argon2_elixir, :argon2_type)
  end

  test "user obfuscation function always returns false" do
    assert Argon2.no_user_verify() == false
  end

  test "duration of user obfuscation function is configurable" do
    {short_time, _} = :timer.tc(Argon2, :no_user_verify, [[t_cost: 1, m_cost: 8]])
    {long_time, _} = :timer.tc(Argon2, :no_user_verify, [[t_cost: 3, m_cost: 12]])
    assert long_time > short_time
  end

  test "invalid stored_hash in verify_pass raises" do
    assert_raise ArgumentError, ~r/check the 'stored_hash' input to verify_pass/, fn ->
      Argon2.verify_pass("", "$someinvalidhash")
    end
  end
end
