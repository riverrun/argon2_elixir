defmodule Argon2.Stats do
  @moduledoc """
  Module to provide statistics for the Argon2 password hashing function.

  The `report/1` function in this module can be used to help you configure
  Argon2.

  ## Configuration

  The following four parameters can be set in the config file
  (these can all be overridden using keyword options):

    * t_cost - time cost
      * the amount of computation, given in number of iterations
      * 8 is the default
    * m_cost - memory usage
      * 17 is the default - this will produce a memory usage of 128 MiB (2 ^ 17 KiB)
    * parallelism - number of parallel threads
      * 4 is the default
    * argon2_type - argon2 variant to use
      * 0 (Argon2d), 1 (Argon2i) or 2 (Argon2id)
      * 2 is the default (Argon2id)

  It is important to note that the default values are not necessarily
  the recommended values. A lot will depend on what hardware you are
  using and how much time you want the hashing function to take. See
  the Choosing parameters section for more details.

  ### Test values

  The following values can be used to speed up tests.

      config :argon2_elixir,
        t_cost: 1,
        m_cost: 8

  NB. do not use these values in production.

  ## Choosing parameters

  The following is a guide on how to choose the parameters.

    1. Decide which type to use. If you do not know the difference between
    the types, choose Argon2id.
    2. Decide how many threads to use - the parallelism option.
    3. Decide how much memory each call should use - m_cost.
    4. Decide how much time each call should take.
      a. The Argon2 draft guidelines recommend 500 milliseconds (0.5 seconds).
    5. Run the function using the values chosen in steps 1-3. Work out
    the maximum t_cost (number of iterations) such that the running time
    does not exceed the value chosen in step 4. If the time taken exceeds
    the value chosen in step 4 even for one iteration, reduce the m_cost
    accordingly.
  """

  alias Argon2.Base

  @doc """
  Hash a password with Argon2 and print out a report.

  This function hashes the password and salt with `Argon2.Base.hash_password/3`
  and prints out statistics which can help you choose how to configure Argon2.

  ## Options

  In addition to the options for `Argon2.Base.hash_password/3`, there are
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

    password
    |> Argon2.verify_pass(encoded)
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
