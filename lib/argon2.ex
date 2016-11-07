defmodule Argon2 do
  @moduledoc """
  Elixir wrapper for the Argon2 password hashing function.

  In most cases, you will just need to use the `hash_pwd_salt/2` and
  `verify_hash/3` functions from this module.

  ## Argon2

  Argon2 is the winner of the [Password Hashing Competition (PHC)](https://password-hashing.net).

  Argon2 is a memory-hard password hashing function which can be used to hash
  passwords for credential storage, key derivation, or other applications.

  Argon2 has the following three variants (Argon2i is the default):

    * Argon2d - suitable for applications with no threats from side-channel
    timing attacks (eg. cryptocurrencies)
    * Argon2i - suitable for password hashing and password-based key derivation
    * Argon2id - a hybrid of Argon2d and Argon2i

  Argon2i, Argon2d, and Argon2id are parametrized by:

    * A **time** cost, which defines the amount of computation realized and
    therefore the execution time, given in number of iterations
    * A **memory** cost, which defines the memory usage, given in kibibytes
    * A **parallelism** degree, which defines the number of parallel threads

  More information is available at the [Argon2 reference C implementation
  repository](https://github.com/P-H-C/phc-winner-argon2)

  """

  alias Argon2.Base

  @doc """
  Generate a random salt.

  The default length for the salt is 16 bytes. We do not recommend using
  a salt shorter than the default.
  """
  def gen_salt(salt_len \\ 16), do: :crypto.strong_rand_bytes(salt_len)

  @doc """
  Generate a random salt and hash a password using Argon2.

  ## Options

  For more information about the options for the underlying hash function,
  see the documentation for Argon2.Base.hash_password/3.

  This function has the following additional option:

    * salt_len - the length of the random salt
      * the default is 16 (the minimum is 8) bytes
      * we do not recommend using a salt less than 16 bytes long

  """
  def hash_pwd_salt(password, opts \\ []) do
    Base.hash_password(password, Keyword.get(opts, :salt_len, 16) |> gen_salt, opts)
  end

  @doc """
  Verify an encoded Argon2 hash.

  ## Options

  There is one option:

    * argon2_type - Argon2 type
      * this value should be 0 (Argon2d), 1 (Argon2i) or 2 (Argon2id)
      * the default is 1 (Argon2i)

  """
  def verify_hash(stored_hash, password, opts \\ [])
  def verify_hash(stored_hash, password, opts) when is_binary(password) do
    hash = :binary.bin_to_list(stored_hash)
    case Base.verify_nif(hash, password, Keyword.get(opts, :argon2_type, 1)) do
      0 -> true
      _ -> false
    end
  end
  def verify_hash(_, _, _) do
    raise ArgumentError, "Wrong type - password should be a string"
  end
end
