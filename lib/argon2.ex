defmodule Argon2 do
  @moduledoc """
  Elixir wrapper for the Argon2 password hashing algorithm.

  In most cases, you will just need to use the `hash_pwd_salt/2` and
  `verify_hash/3` functions.
  """

  alias Argon2.Base

  @doc """
  Generate a random salt.
  """
  def gen_salt(salt_len \\ 16), do: :crypto.strong_rand_bytes(salt_len)

  @doc """
  Hash a password using Argon2.

  ## Options

  There are six options:

    * t_cost
    * m_cost
    * parallelism
    * encode_output
    * hashlen
    * argon2_type

  """
  def hash_password(password, salt, opts \\ [])
  def hash_password(password, salt, opts) when is_binary(password) and is_binary(salt) do
    {t, m, p, encode, hashlen, argon2_type} = get_opts(opts)
    {raw_output, encodedlen} = if encode do
      {0, Base.encodedlen_nif(t, m, p, byte_size(salt), hashlen, argon2_type)}
    else
      {1, 0}
    end
    Base.hash_nif(t, m, p, password, salt, raw_output, hashlen, encodedlen, argon2_type, 0)
    |> handle_result
  end
  def hash_password(_, _, _) do
    raise ArgumentError, "Wrong type - password and salt should be strings"
  end

  @doc """
  Generate a random salt and hash a password using Argon2.
  """
  def hash_pwd_salt(password, opts \\ []) do
    hash_password(password, Keyword.get(opts, :salt_len, 16) |> gen_salt, opts)
  end

  @doc """
  Verify an encoded Argon2 hash.
  """
  def verify_hash(stored_hash, password, opts \\ [])
  def verify_hash(stored_hash, password, opts) when is_binary(password) do
    hash = :binary.bin_to_list(stored_hash)
    Base.verify_nif(hash, password, Keyword.get(opts, :argon2_type, 1))
    |> handle_result
  end
  def verify_hash(_, _, _) do
    raise ArgumentError, "Wrong type - password should be a string"
  end

  defp get_opts(opts) do
    {Keyword.get(opts, :t_cost, 3),
      Keyword.get(opts, :m_cost, 12),
      Keyword.get(opts, :parallelism, 1),
      Keyword.get(opts, :encode_output, true),
      Keyword.get(opts, :hashlen, 32),
      Keyword.get(opts, :argon2_type, 1)}
  end

  defp handle_result(0), do: true
  defp handle_result(-35), do: false
  defp handle_result(result) when is_integer(result) do
    msg = Base.error_nif(result) |> :binary.list_to_bin
    raise ArgumentError, msg
  end
  defp handle_result({[], encoded}), do: :binary.list_to_bin(encoded)
  defp handle_result({raw, _}), do: :binary.list_to_bin(raw)
end
