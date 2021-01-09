defmodule Argon2.Mixfile do
  use Mix.Project

  @version "2.4.0"

  @description """
  Argon2 password hashing algorithm for Elixir
  """

  def project do
    [
      app: :argon2_elixir,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_targets: ["all"],
      make_clean: ["clean"],
      description: @description,
      package: package(),
      source_url: "https://github.com/riverrun/argon2_elixir",
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:comeonin, "~> 5.3"},
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "c_src", "argon2/include", "argon2/src", "mix.exs", "Makefile*", "README.md"],
      maintainers: ["David Whitlock"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/riverrun/argon2_elixir"}
    ]
  end
end
