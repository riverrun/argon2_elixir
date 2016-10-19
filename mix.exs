defmodule Argon2.Mixfile do
  use Mix.Project

  @version "0.1.0"

  @description """
  Argon2 password hashing function for Elixir
  """

  def project do
    [app: :argon2_elixir,
     version: @version,
     elixir: "~> 1.4-dev",
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
    [{:elixir_make, "~> 0.3"}]
  end

  defp package do
    [files: ["lib", "argon2/include", "argon2/src", "mix.exs", "Makefile*", "README.md", "LICENSE"],
     maintainers: ["David Whitlock"],
     licenses: ["Apache"],
     links: %{"GitHub" => "https://github.com/riverrun/argon2_elixir",
      "Docs" => "http://hexdocs.pm/argon2_elixir"}]
  end
end
