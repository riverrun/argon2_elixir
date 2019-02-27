ExUnit.start()

defmodule Argon2TestHelper do
  use ExUnit.Case

  alias Argon2.Base

  def hashtest(version, t, m, p, pwd, salt, hexref, mcfref) do
    hashlen = 32
    encodedlen = 108
    {hash, encoded} = Base.hash_nif(t, m, p, pwd, salt, 1, hashlen, encodedlen, 1, version)
    assert :binary.list_to_bin(hash) == hexref
    refute is_integer(encoded)
    assert length(hash) == hashlen * 2
    if version > 0x10, do: assert(:binary.list_to_bin(encoded) == mcfref)
    assert Base.verify_nif(encoded, pwd, 1) == 0
  end

  def verify_test_helper(stored_hash, password, version) do
    Base.verify_nif(:binary.bin_to_list(stored_hash), password, version)
  end
end
