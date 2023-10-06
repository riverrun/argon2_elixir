defmodule Argon2.StatsTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Argon2.Stats

  test "print report with default options" do
    report = capture_io(fn -> Stats.report() end)
    assert report =~ ~r/Iterations:\t3(\r)?\n/
    assert report =~ ~r/Memory:\t\t64 MiB(\r)?\n/
    assert report =~ ~r/Parallelism:\t4(\r)?\n/
    assert report =~ "Verification OK"
  end

  test "use custom options" do
    opts = [t_cost: 4, m_cost: 18, parallelism: 2]
    report = capture_io(fn -> Stats.report(opts) end)
    assert report =~ ~r/Iterations:\t4(\r)?\n/
    assert report =~ ~r/Memory:\t\t256 MiB(\r)?\n/
    assert report =~ ~r/Parallelism:\t2(\r)?\n/
    assert report =~ "Verification OK"
  end
end
