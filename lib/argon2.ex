defmodule Argon2 do
  @moduledoc """
  Elixir wrapper for the Argon2 password hashing function.

  This library can be used on its own, or it can be used together with
  [Comeonin](https://hexdocs.pm/comeonin/api-reference.html), which
  provides a higher-level api.

  Before using Argon2, you will need to configure it. Read the documentation
  for Argon2.Stats for more information about configuration. After that,
  most users will just need to use the `hash_pwd_salt/2` and `verify_pass/3`
  functions from this module.

  For a lower-level API, see Argon2.Base.

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

  More information can be found in the documentation for the Argon2.Stats
  module and at the [Argon2 reference C implementation
  repository](https://github.com/P-H-C/phc-winner-argon2).

  ## Comparison with Bcrypt / Pbkdf2

  Currently, the most popular password hashing functions are Bcrypt,
  which was presented in 1999, and Pbkdf2 (pbkdf2_sha256 or pbkdf2_sha512),
  which dates back to 2000. Both are strong password hashing functions
  with no known vulnerabilities, and their algorithms have been used and
  widely reviewed for over 10 years. To help you decide whether you should
  use Argon2 instead, here is a brief comparison of Bcrypt / Pbkdf2 with
  Argon2.

  Argon2 is a lot newer, and this can be considered to be both an
  advantage and a disadvantage. On the one hand, Argon2 benefits
  from more recent research, and it is designed to combat the kinds
  of attacks which have become more common over the past decade,
  such as the use of GPUs or dedicated hardware. On the other hand,
  Argon2 has not received the same amount of scrutiny that Bcrypt / Pbkdf2
  has.

  One of the main differences is that Argon2 is a memory-hard function,
  and this means that it is designed to use a lot more memory than
  Bcrypt / Pbkdf2. With Bcrypt / Pbkdf2, attackers can use GPUs to hash
  several hundred / thousand passwords in parallel. This can result in
  significant gains in the time it takes an attacker to crack passwords.
  Argon2's memory cost means that it is a lot more difficult for attackers
  to benefit from using GPUs or other dedicated hardware.
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

    * `:salt_len` - the length of the random salt
      * the default is 16 (the minimum is 8) bytes
      * we do not recommend using a salt less than 16 bytes long

  ## Examples

  The following example changes the default `t_cost` and `m_cost`:

      Argon2.hash_pwd_salt("password", [t_cost: 8, m_cost: 20])

  In the example below, the Argon2 type is changed to Argon2id:

      Argon2.hash_pwd_salt("password", [argon2_type: 2])

  To use Argon2d, use `argon2_type: 0`.
  """
  def hash_pwd_salt(password, opts \\ []) do
    Base.hash_password(password, Keyword.get(opts, :salt_len, 16) |> gen_salt, opts)
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.
  """
  def verify_pass(password, stored_hash) do
    hash = :binary.bin_to_list(stored_hash)

    case Base.verify_nif(hash, password, argon2_type(stored_hash)) do
      0 -> true
      _ -> false
    end
  end

  @doc """
  Verify an encoded Argon2 hash.

  This function is deprecated, and it will be removed in version 2.0.
  Please use `verify_pass` instead.
  """
  def verify_hash(stored_hash, password, opts \\ [])

  def verify_hash(stored_hash, password, _) do
    IO.puts(:stderr, "Argon2.verify_hash is deprecated - please use Argon2.verify_pass instead")
    hash = :binary.bin_to_list(stored_hash)

    case Base.verify_nif(hash, password, argon2_type(stored_hash)) do
      0 -> true
      _ -> false
    end
  end

  @doc """
  A dummy verify function to help prevent user enumeration.

  This function hashes the password and then returns false, and it is
  intended to make it more difficult for any potential attacker to find
  valid usernames by using timing attacks. This function is only useful
  if it is used as part of a policy of hiding usernames. For more information,
  see the section below on username obfuscation.

  It is important that this function is called with the same options
  that are used to hash the password.

  ## Example

  The following example looks for the user in the database and checks the
  password with the stored password hash if the user is found. It then
  returns the user struct, if the password is correct, or false. If no user
  is found, the `no_user_verify` function is called. This will take the same
  time to run as the `verify_pass` function. This means that the end user
  will not be able to find valid usernames just by timing the responses.

      def verify_password(username, password) do
        case Repo.get_by(User, username: username) do
          nil -> Argon2.no_user_verify()
          user -> Argon2.verify_pass(password, user.password_hash) && user
        end
      end

  ## Username obfuscation

  In addition to keeping passwords secret, hiding the precise username
  can help make online attacks more difficult. An attacker would then
  have to guess a username / password combination, rather than just
  a password, to gain access.

  This does not mean that the username should be kept completely secret.
  Adding a short numerical suffix to a user's name, for example, would be
  sufficient to increase the attacker's work considerably.

  If you are implementing a policy of hiding usernames, it is important
  to make sure that the username is not revealed by any other part of
  your application.
  """
  def no_user_verify(opts \\ []) do
    hash_pwd_salt("", opts)
    false
  end

  defp argon2_type("$argon2id" <> _), do: 2
  defp argon2_type("$argon2i" <> _), do: 1
  defp argon2_type("$argon2d" <> _), do: 0

  defp argon2_type(_) do
    raise ArgumentError,
          "Invalid Argon2 hash. " <> "Please check the 'stored_hash' input to verify_pass."
  end
end
