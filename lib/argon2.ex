defmodule Argon2 do
  @moduledoc """
  Elixir wrapper for the Argon2 password hashing function.

  Most applications will just need to use the `add_hash/2` and `check_pass/3`
  convenience functions in this module.

  For a lower-level API, see `Argon2.Base`.

  ## Configuration

  See the documentation for `Argon2.Stats` for information about configuration.

  ## Argon2

  Argon2 is the winner of the [Password Hashing Competition (PHC)](https://password-hashing.net).

  Argon2 is a memory-hard password hashing function which can be used to hash
  passwords for credential storage, key derivation, or other applications.

  Argon2 has the following three variants (Argon2id is the default):

    * Argon2d - suitable for applications with no threats from side-channel
    timing attacks (eg. cryptocurrencies)
    * Argon2i - suitable for password hashing and password-based key derivation
    * Argon2id - a hybrid of Argon2d and Argon2i

  Argon2i, Argon2d, and Argon2id are parametrized by:

    * A **time** cost, which defines the amount of computation realized and
    therefore the execution time, given in number of iterations
    * A **memory** cost, which defines the memory usage, given in kibibytes
    * A **parallelism** degree, which defines the number of parallel threads

  More information can be found in the documentation for the `Argon2.Stats`
  module and at the [Argon2 reference C implementation
  repository](https://github.com/P-H-C/phc-winner-argon2).

  ## Comparison with Bcrypt / Pbkdf2

  Argon2 has better password cracking resistance than Bcrypt and Pbkdf2.
  Its main advantage is that, as it is a memory-hard function, it is designed
  to withstand parallel attacks that use GPUs or other dedicated hardware.
  """

  use Comeonin

  alias Argon2.Base

  @doc """
  Generate a random salt.

  The default length for the salt is 16 bytes. We do not recommend using
  a salt shorter than the default.
  """
  def gen_salt(salt_len \\ 16), do: :crypto.strong_rand_bytes(salt_len)

  @doc """
  Hashes a password with a randomly generated salt.

  ## Options

  In addition to the `:salt_len` option shown below, this function also takes
  options that are then passed on to the `hash_password` function in the
  `Argon2.Base` module.

  See the documentation for `Argon2.Base.hash_password/3` for further details.

    * `:salt_len` - the length of the random salt
      * the default is 16 (the minimum is 8) bytes

  ## Examples

  The following examples show how to hash a password with a randomly-generated
  salt and then verify a password:

      iex> hash = Argon2.hash_pwd_salt("password")
      ...> Argon2.verify_pass("password", hash)
      true

      iex> hash = Argon2.hash_pwd_salt("password")
      ...> Argon2.verify_pass("incorrect", hash)
      false

  """
  @impl true
  def hash_pwd_salt(password, opts \\ []) do
    Base.hash_password(password, Keyword.get(opts, :salt_len, 16) |> gen_salt, opts)
  end

  @doc """
  Verifies a password by hashing the password and comparing the hashed value
  with a stored hash.

  See the documentation for `hash_pwd_salt/2` for examples of using this function.
  """
  @impl true
  def verify_pass(password, stored_hash) do
    hash = :binary.bin_to_list(stored_hash)

    case Base.verify_nif(hash, password, argon2_type(stored_hash)) do
      0 -> true
      -35 -> false
      error -> raise ArgumentError, Base.handle_error(error)
    end
  end

  defp argon2_type("$argon2id" <> _), do: 2
  defp argon2_type("$argon2i" <> _), do: 1
  defp argon2_type("$argon2d" <> _), do: 0

  defp argon2_type(_) do
    raise ArgumentError,
          "Invalid Argon2 hash. " <> "Please check the 'stored_hash' input to verify_pass."
  end
end
