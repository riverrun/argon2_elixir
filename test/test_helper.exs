ExUnit.start()

defmodule Argon2TestHelper do
  use ExUnit.Case

  alias Argon2.Base

  def hashtest(version, t, m, p, pwd, salt, hexref, mcfref) do
    hashlen = 32
    hashspace = hashlen * 2 + 1
    encodedlen = 108
    {hash, encoded} = Base.hash_nif(t, m, p, pwd, salt, 1, hashlen, hashspace, encodedlen, 1, version)
    assert :binary.list_to_bin(hash) == hexref
    refute is_integer(encoded)
    assert length(hash) == hashlen * 2
    if version > 0x10, do: assert :binary.list_to_bin(encoded) == mcfref
    assert Base.verify_nif(encoded, pwd, 1) == 0
  end

  def verify_test_helper(stored_hash, password, version) do
    Base.verify_nif(:binary.bin_to_list(stored_hash),
                    password, version)
  end

  def encoded_hash_check(password) do
    wrong_list = wrong_passwords(password)
    for argon2_type <- 0..2 do
      encoded = Argon2.hash_pwd_salt(password, [t_cost: 3, m_cost: 12, argon2_type: argon2_type])
      assert Argon2.verify_pass(password, encoded)
      for wrong <- wrong_list do
        refute Argon2.verify_pass(wrong, encoded)
      end
    end
  end

  defp wrong_passwords(password) do
    (for num <- 2..6, do: String.duplicate(password, num)) ++
    (for num <- 0..9, do: password <> Integer.to_string(num)) ++
    slices(password) ++ [String.reverse(password), ""]
  end

  defp slices(password) do
    ranges = [{1, -1}, {0, -2}, {2, -1}, {0, -3}, {2, -2}, {1, -3},
              {3, -2}, {2, -3}]
    for {first, last} <- ranges, do: String.slice(password, first..last)
  end
end
