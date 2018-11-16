defmodule Argon2.Mixfile do
  use Mix.Project

  @version "1.3.3"

  @description """
  Argon2 password hashing algorithm for Elixir
  """

  def project do
    [
      app: :argon2_elixir,
      version: @version,
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      description: @description,
      package: package(),
      source_url: "https://github.com/riverrun/argon2_elixir",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
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
