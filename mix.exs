defmodule Argon2.Mixfile do
  use Mix.Project

  @version "0.11.2"

  @description """
  Argon2 password hashing algorithm for Elixir
  """

  def project do
    [app: :argon2_elixir,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     compilers: [:elixir_make] ++ Mix.compilers,
     description: @description,
     package: package(),
     source_url: "https://github.com/riverrun/argon2_elixir",
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:elixir_make, "~> 0.4"},
     {:earmark, "~> 1.0", only: :dev},
     {:ex_doc,  "~> 0.14", only: :dev}]
  end

  defp package do
    [files: ["lib", "c_src", "argon2/include", "argon2/src", "mix.exs", "Makefile*", "README.md"],
     maintainers: ["David Whitlock"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/riverrun/argon2_elixir",
      "Docs" => "http://hexdocs.pm/argon2_elixir"}]
  end
end
