defmodule Argon2.Base do
  @moduledoc """
  Lower-level api for Argon2.

  These functions can be useful if you want more control over some
  of the options. In most cases, you will not need to call these
  functions directly.
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  def init do
    case load_nif() do
      :ok ->
        :ok

      _ ->
        raise """
        An error occurred when loading Argon2.
        Make sure you have a C compiler and Erlang 20 installed.
        If you are not using Erlang 20, either upgrade to Erlang 20 or
        use bcrypt_elixir (version 0.12) or pbkdf2_elixir.
        See the Comeonin wiki for more information.
        """
    end
  end

  @doc """
  Hash a password using Argon2.
  """
  def hash_nif(
        t_cost,
        m_cost,
        parallelism,
        password,
        salt,
        raw,
        hashlen,
        encodedlen,
        argon2_type,
        argon2_version
      )

  def hash_nif(_, _, _, _, _, _, _, _, _, _), do: :erlang.nif_error(:not_loaded)

  @doc """
  Verify a password using Argon2.
  """
  def verify_nif(stored_hash, password, argon2_type)
  def verify_nif(_, _, _), do: :erlang.nif_error(:not_loaded)

  @doc """
  Translate the error code to an error message.
  """
  def error_nif(error_code)
  def error_nif(_), do: :erlang.nif_error(:not_loaded)

  @doc """
  Calculate the length of the encoded hash.
  """
  def encodedlen_nif(t_cost, m_cost, parallelism, saltlen, hashlen, argon2_type)
  def encodedlen_nif(_, _, _, _, _, _), do: :erlang.nif_error(:not_loaded)

  @doc """
  Hash a password using Argon2.

  ## Configurable parameters

  The following three parameters can be set in the config file:

    * t_cost - time cost
      * the amount of computation, given in number of iterations
      * 6 is the default
    * m_cost - memory usage
      * 16 is the default - this will produce a memory usage of 2 ^ 16 KiB (64 MiB)
    * parallelism - number of parallel threads
      * 1 is the default
    * argon2_type - argon2 variant to use
      * 0 (Argon2d), 1 (Argon2i) or 2 (Argon2id)
      * 1 is the default (Argon2i)

  ### Production values

  See the documentation for Argon2.Stats.

  ### Test values

  The following values can be used to speed up tests.

      config :argon2_elixir,
        t_cost: 1,
        m_cost: 8

  NB. do not use these values in production.

  ## Options

  There are six options (t_cost, m_cost, parallelism and argon2_type can be used
  to override the values set in the config):

    * `:t_cost` - time cost
    * `:m_cost` - memory usage
    * `:parallelism` - number of parallel threads
    * `:format` - output format
      * this value can be
        * `:encoded` - encoded with Argon2 crypt format
        * `:raw_hash` - raw hash output in hexadecimal format
        * `:report` - raw hash and encoded hash, together with the options used
      * `:encoded` is the default
    * `:hashlen` - length of the hash (in bytes)
      * the default is 32
    * `:argon2_type` - Argon2 type
      * this value should be 0 (Argon2d), 1 (Argon2i) or 2 (Argon2id)
      * the default is 1 (Argon2i)

  ## Examples

  The following example changes the default `t_cost` and `m_cost`:

      Argon2.Base.hash_password("password", "somesaltSOMESALT", [t_cost: 8, m_cost: 20])

  In the example below, the Argon2 type is changed to Argon2id:

      Argon2.Base.hash_password("password", "somesaltSOMESALT", [argon2_type: 2])

  To use Argon2d, use `argon2_type: 0`.
  """
  def hash_password(password, salt, opts \\ []) do
    {t, m, p, hashlen, argon2_type} = options = hash_opts(opts)
    format = output_opts(opts[:format])

    encodedlen =
      (format == 1 and 0) || encodedlen_nif(t, m, p, byte_size(salt), hashlen, argon2_type)

    hash_nif(t, m, p, password, salt, format, hashlen, encodedlen, argon2_type, 0)
    |> handle_result(options, format)
  end

  defp load_nif do
    path = :filename.join(:code.priv_dir(:argon2_elixir), 'argon2_nif')
    :erlang.load_nif(path, 0)
  end

  defp hash_opts(opts) do
    {
      Keyword.get(opts, :t_cost, Application.get_env(:argon2_elixir, :t_cost, 6)),
      Keyword.get(opts, :m_cost, Application.get_env(:argon2_elixir, :m_cost, 16)),
      Keyword.get(opts, :parallelism, Application.get_env(:argon2_elixir, :parallelism, 1)),
      Keyword.get(opts, :hashlen, 32),
      Keyword.get(opts, :argon2_type, Application.get_env(:argon2_elixir, :argon2_type, 1))
    }
  end

  defp output_opts(:raw_hash), do: 1
  defp output_opts(:report), do: 2
  defp output_opts(_), do: 0

  defp handle_result(result, _, _) when is_integer(result) do
    msg = error_nif(result) |> :binary.list_to_bin()
    raise ArgumentError, msg
  end

  defp handle_result({_, encoded}, _, 0), do: :binary.list_to_bin(encoded)
  defp handle_result({raw, _}, _, 1), do: :binary.list_to_bin(raw)

  defp handle_result({raw, encoded}, options, 2) do
    {:binary.list_to_bin(raw), :binary.list_to_bin(encoded), options}
  end
end
