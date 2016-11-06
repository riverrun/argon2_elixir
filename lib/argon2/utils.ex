defmodule Argon2.Utils do
  @moduledoc """
  Various tools.
  """

  alias Argon2.Base

  @doc """
  Hash a password with Argon2 and print out a report.
  """
  def report(password, salt, opts \\ []) do
    {t, m, p, _, _, hashlen, argon2_type} = Base.get_opts(opts)
    encodedlen = Base.encodedlen_nif(t, m, p, byte_size(salt), hashlen, argon2_type)
    {exec_time, {raw, encoded}} = :timer.tc(Base, :hash_nif,
      [t, m, p, password, salt, 1, hashlen, encodedlen, argon2_type, 0])
    Base.verify_nif(encoded, password, argon2_type)
    |> format_result(argon2_type, t, m, p, raw, encoded, exec_time)
  end

  defp format_result(check, argon2_type, t, m, p, raw, encoded, exec_time) do
    IO.puts """
    Type:\t\t#{format_type(argon2_type)}
    Iterations:\t#{t}
    Memory:\t\t#{m}
    Parallelism:\t#{p}
    Hash:\t\t#{:binary.list_to_bin(raw)}
    Encoded:\t#{:binary.list_to_bin(encoded)}
    #{format_time(exec_time)} seconds
    Verification #{if check == 0, do: "ok", else: "failed"}
    """
  end

  defp format_type(0), do: "Argon2d"
  defp format_type(1), do: "Argon2i"
  defp format_type(2), do: "Argon2id"

  defp format_time(time) do
    Float.round(time / 1_000_000, 2)
  end
end
