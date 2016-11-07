defmodule Argon2.Utils do
  @moduledoc """
  Tools to be used with Argon2.
  """

  alias Argon2.Base

  @doc """
  Hash a password with Argon2 and print out a report.

  ## Options

  See the documentation for Argon2.Base.hash_password/3 for details
  about all the available options.
  """
  def report(password, salt, opts \\ []) do
    {exec_time, result} = :timer.tc(Base, :hash_password, [password, salt, opts ++ [format: :report]])
    {raw, encoded, {t, m, p, _, _, _, argon2_type}} = result
    Argon2.verify_hash(encoded, password, argon2_type: argon2_type)
    |> format_result(argon2_type, t, m, p, raw, encoded, exec_time)
  end

  defp format_result(check, argon2_type, t, m, p, raw, encoded, exec_time) do
    IO.puts """
    Type:\t\t#{format_type(argon2_type)}
    Iterations:\t#{t}
    Memory:\t\t#{trunc(:math.pow(2, m - 10))} MiB
    Parallelism:\t#{p}
    Hash:\t\t#{raw}
    Encoded:\t#{encoded}
    #{format_time(exec_time)} seconds
    Verification #{if check, do: "ok", else: "failed"}
    """
  end

  defp format_type(0), do: "Argon2d"
  defp format_type(1), do: "Argon2i"
  defp format_type(2), do: "Argon2id"

  defp format_time(time) do
    Float.round(time / 1_000_000, 2)
  end
end
