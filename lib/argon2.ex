defmodule Argon2 do
  @moduledoc """
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    path = :filename.join(:code.priv_dir(:argon2_elixir), 'argon2_nif')
    :erlang.load_nif(path, 0)
  end

  @doc """
  """
  def gen_salt(salt_len \\ 16), do: :crypto.strong_rand_bytes(salt_len)

  def argon2_hash_nif(t_cost, m_cost, parallelism, password, salt, hashlen, encoded, argon2_type)
  def argon2_hash_nif(_, _, _, _, _, _, _, _), do: exit(:nif_library_not_loaded)

  def argon2_verify_nif(stored_hash, password, argon2_type)
  def argon2_verify_nif(_, _, _), do: exit(:nif_library_not_loaded)

  @doc """
  """
  def hash_password(password, salt, opts \\ [])
  def hash_password(_, salt, _) when byte_size(salt) < 8 do
    raise ArgumentError, "The salt is too short - it should be 8 characters or longer"
  end
  def hash_password(password, salt, opts) do
    argon2_hash_nif(Keyword.get(opts, :t_cost, 3),
                    Keyword.get(opts, :m_cost, 12),
                    Keyword.get(opts, :parallelism, 1),
                    password,
                    salt,
                    Keyword.get(opts, :hashlen, 32),
                    Keyword.get(opts, :encoded, 1),
                    Keyword.get(opts, :argon2_type, 1))
    |> :binary.list_to_bin
  end

  @doc """
  """
  def hash_pwd_salt(password, opts \\ []) do
    salt = Keyword.get(opts, :salt_len, 16) |> gen_salt
    hash_password(password, salt, opts)
  end

  @doc """
  """
  def verify_hash(stored_hash, password, opts \\ []) do
    hash = :binary.bin_to_list(stored_hash)
    case argon2_verify_nif(hash, password, Keyword.get(opts, :argon2_type, 1)) do
      0 -> true
      _ -> false
    end
  end
end
