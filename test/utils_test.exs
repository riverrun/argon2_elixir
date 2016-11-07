defmodule Argon2UtilsTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  alias Argon2.Utils

  test "print report with default options" do
    report = capture_io(fn -> Utils.report("password", "somesalt", []) end)
    assert report =~ "Iterations:\t6\n"
    assert report =~ "Memory:\t\t64 MiB\n"
    assert report =~ "Parallelism:\t1\n"
    assert report =~ "Verification ok"
  end

  test "use custom options" do
    opts = [t_cost: 8, m_cost: 18, parallelism: 4]
    report = capture_io(fn -> Utils.report("password", "somesalt", opts) end)
    assert report =~ "Iterations:\t8\n"
    assert report =~ "Memory:\t\t256 MiB\n"
    assert report =~ "Parallelism:\t4\n"
    assert report =~ "Verification ok"
  end

end
