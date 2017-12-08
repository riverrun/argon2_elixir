defmodule Argon2.Stats do
  @moduledoc """
  Module to provide statistics for the Argon2 password hashing function.

  The default parameters are:

    * t_cost: 6
    * m_cost: 16 (64 MiB of memory)
    * parallelism: 1

  However, the parameters you use depend a lot on the hardware you are
  using, and so it is important to measure the function's running time
  and adjust the parameters accordingly.

  Below is a guide on how to choose the parameters and what kind of
  running time is recommended.

  ## Choosing parameters

    1. Decide how much memory the function should use
    2. Decide how many threads to use
    3. Set the t_cost to 3 and measure the time it takes to hash a password
      * If the function is too slow, reduce memory usage, but keep t_cost at 3
      * If the function is too fast, increase the t_cost

  For online use - for example, logging in on a website - the function should
  take anything between 250 milliseconds and one second. For a desktop
  application, the function could take longer, anything from several seconds
  to 5 seconds, as long as the user only has to log in once per session.
  These numbers are based on the [libsodium documentation for
  Argon2i](https://download.libsodium.org/doc/password_hashing/the_argon2i_function.html)
  and the previous
  [NIST recommendations](http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-132.pdf).
  """

  alias Argon2.Base

  @doc """
  Hash a password with Argon2 and print out a report.

  This function hashes the password and salt with Argon2.Base.hash_password/3
  and prints out statistics which can help you choose how to configure Argon2.

  ## Options

  In addition to the options for Argon2.Base.hash_password/3, there are
  also the following options:

    * `:password` - the password used
      * the default is "password"
    * `:salt` - the salt used
      * the default is "somesaltSOMESALT"

  """
  def report(opts \\ []) do
    password = Keyword.get(opts, :password, "password")
    salt = Keyword.get(opts, :salt, "somesaltSOMESALT")

    {exec_time, result} =
      :timer.tc(Base, :hash_password, [password, salt, [format: :report] ++ opts])

    {raw, encoded, {t, m, p, _, argon2_type}} = result

    Argon2.verify_pass(password, encoded)
    |> format_result(argon2_type, t, m, p, raw, encoded, exec_time)
  end

  defp format_result(check, argon2_type, t, m, p, raw, encoded, exec_time) do
    IO.puts("""
    Type:\t\t#{format_type(argon2_type)}
    Iterations:\t#{t}
    Memory:\t\t#{trunc(:math.pow(2, m - 10))} MiB
    Parallelism:\t#{p}
    Hash:\t\t#{raw}
    Encoded:\t#{encoded}
    Time taken:\t#{format_time(exec_time)} seconds
    Verification #{if check, do: "OK", else: "FAILED"}
    """)
  end

  defp format_type(0), do: "Argon2d"
  defp format_type(1), do: "Argon2i"
  defp format_type(2), do: "Argon2id"

  defp format_time(time) do
    Float.round(time / 1_000_000, 2)
  end
end
