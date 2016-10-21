vars = [{Argon2.Argon2d, 0},
 {Argon2.Argon2i, 1},
 {Argon2.Argon2id, 2}]

for {mod, argon2_type} <- vars do
  defmodule mod do
    @moduledoc """
    """

    def hash_password(password, t_cost \\ 2, m_cost \\ 16, parallelism \\ 1, hashlen \\ 32) do
      hash_encoded(t_cost, m_cost, parallelism, password, Argon2.gen_salt(16), hashlen)
    end

    def hash_raw(t_cost, m_cost, parallelism, password, salt, hashlen) do
      Argon2.argon2_hash_nif(t_cost, m_cost, parallelism, password, salt,
                      hashlen, 1, unquote(argon2_type))
      |> :binary.list_to_bin
    end

    def hash_encoded(t_cost, m_cost, parallelism, password, salt, hashlen) do
      Argon2.argon2_hash_nif(t_cost, m_cost, parallelism, password, salt,
                      hashlen, 0, unquote(argon2_type))
      |> :binary.list_to_bin
    end

    def verify_hash(stored_hash, password) do
      case Argon2.argon2_verify_nif(to_char_list(stored_hash), password, unquote(argon2_type)) do
        0 -> true
        _ -> false
      end
    end
  end
end
