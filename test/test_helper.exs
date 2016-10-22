ExUnit.start()

defmodule Argon2TestHelper do
  use ExUnit.Case

  def hash_check(password) do
    wrong_list = wrong_passwords(password)
    for argon2_type <- 0..2 do
      hash = Argon2.hash_pwd_salt(password, [argon2_type: argon2_type])
      assert Argon2.verify_hash(hash, password, [argon2_type: argon2_type])
      for wrong <- wrong_list do
        refute Argon2.verify_hash(hash, wrong, [argon2_type: argon2_type])
      end
    end
  end

  def known_vectors do
    [{0, "45d7ac72e76f242b20b77b9bf9bf9d5915894e669a24e6c6"},
     {1, "$argon2i$v=19$m=65536,t=2,p=4$c29tZXNhbHQ$RdescudvJCsgt3ub+b+dWRWJTmaaJObG"}]
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
