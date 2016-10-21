defmodule Argon2 do
  @moduledoc """
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:argon2_elixir), 'argon2_nif')
    :erlang.load_nif(path, 0)
  end

  def gen_salt(salt_len \\ 16), do: :crypto.strong_rand_bytes(salt_len)

  def argon2_hash_nif(t_cost, m_cost, parallelism, password, salt, hashlen, raw, argon2_type)
  def argon2_hash_nif(_, _, _, _, _, _, _, _), do: exit(:nif_library_not_loaded)

  def argon2_verify_nif(stored_hash, password, argon2_type)
  def argon2_verify_nif(_, _, _), do: exit(:nif_library_not_loaded)

  def hash_raw(t_cost, m_cost, parallelism, password, salt, hashlen, argon2_type) do
    argon2_hash_nif(t_cost, m_cost, parallelism, password, salt, hashlen, 1, argon2_type)
    |> :binary.list_to_bin
  end

  def hash_encoded(t_cost, m_cost, parallelism, password, salt, hashlen, argon2_type) do
    argon2_hash_nif(t_cost, m_cost, parallelism, password, salt, hashlen, 0, argon2_type)
    |> :binary.list_to_bin
  end

  def hash_test(password, raw) do
    salt = gen_salt(16)
    if raw do
      hash_raw(2, 16, 1, password, salt, 32, 1)
    else
      hash_encoded(2, 16, 1, password, salt, 32, 1)
    end
  end

  def verify(stored_hash, password) do
  end
end
