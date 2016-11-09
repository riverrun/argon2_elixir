defmodule Argon2Test do
  use ExUnit.Case

  import Argon2TestHelper
  alias Argon2.Base

  test "only output encoded hash" do
    result = Base.hash_password("password", "somesalt")
    assert is_binary(result)
    assert String.starts_with?(result, "$argon2i$v=19$m=65536,t=6,p=1")
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
    assert String.starts_with?(encoded, "$argon2i$v=19$m=65536,t=6,p=1")
  end

  test "customizing parameters with config" do
    Application.put_env(:argon2_elixir, :t_cost, 3)
    Application.put_env(:argon2_elixir, :m_cost, 12)
    result = Base.hash_password("password", "somesalt")
    assert String.starts_with?(result, "$argon2i$v=19$m=4096,t=3,p=1")
    Application.delete_env(:argon2_elixir, :t_cost)
    Application.delete_env(:argon2_elixir, :m_cost)
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

end
