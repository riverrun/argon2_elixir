# Argon2

Argon2 password hashing for Elixir.

So far, this has only been tested on Linux. If you have any difficulties installing
or using it on your platform, please open an issue.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `argon2_elixir` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:argon2_elixir, "~> 0.8"}]
    end
    ```

  2. Ensure `argon2_elixir` is started before your application:

    ```elixir
    def application do
      [applications: [:argon2_elixir]]
    end
    ```

## Use

Most users will just need to use the `hash_pwd_salt/2` and `verify_hash/3`
functions in the Argon2 module.

`hash_pwd_salt` generates a random salt and creates a hash from a password.

`verify_hash` takes a stored hash and a password and checks that the hash
is correct.

Please read the documentation for the Argon2 module for more information.

### License

Apache 2.0
