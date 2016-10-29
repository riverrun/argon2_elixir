defmodule Argon2Test do
  use ExUnit.Case

  import Argon2TestHelper

  test "only output encoded hash" do
    result = Argon2.hash_password("password", "somesalt")
    assert is_binary(result)
    assert String.starts_with?(result, "$argon2")
  end

  test "only output raw hash" do
    result = Argon2.hash_password("password", "somesalt", encode_output: false)
    assert is_binary(result)
    refute String.starts_with?(result, "$argon2")
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
