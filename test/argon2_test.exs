defmodule Argon2Test do
  use ExUnit.Case

  import Argon2TestHelper
  alias Argon2.Base

  test "only output encoded hash" do
    result = Base.hash_password("password", "somesalt")
    assert is_binary(result)
    assert String.starts_with?(result, "$argon2")
  end

  test "only output raw hash" do
    result = Base.hash_password("password", "somesalt", format: :raw_hash)
    assert is_binary(result)
    refute String.starts_with?(result, "$argon2")
  end

  test "output both raw and encoded hash" do
    {raw, encoded} = Base.hash_password("password", "somesalt", format: :report)
    assert is_binary(raw)
    assert is_binary(encoded)
    refute String.starts_with?(raw, "$argon2")
    assert String.starts_with?(encoded, "$argon2")
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
