defmodule Argon2Test do
  use ExUnit.Case

  import Argon2TestHelper

  test "hashing and checking passwords" do
    hash_check("password")
    hash_check("hard2guess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash_check("aáåäeéêëoôö")
    hash_check("aáåä eéêëoôö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash_check("Сколько лет, сколько зим")
    hash_check("สวัสดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    hash_check("Я❤três☕ où☔")
  end

  test "known test vectors" do
    for {arg, result} <- known_vectors() do
      assert Argon2.hash_password("password", "somesalt",
                                  t_cost: 2, m_cost: 16, parallelism: 4,
                                  hashlen: 24, encoded: arg) == result
    end
  end

end
