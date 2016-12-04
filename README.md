# Argon2

Argon2 password hashing for Elixir.

[Argon2](https://github.com/P-H-C/phc-winner-argon2) is the official winner of the
Password Hashing Competition, a several year project to identify a successor to
bcrypt / PBKDF2 / scrypt password hashing methods.

This has been tested on Linux and Mac OS X.
It builds on Windows, but it has not been tested with dirty schedulers
enabled yet.
If you have any difficulties installing or using it on your platform,
please open an issue.

## Requirements

* Elixir version 1.3 or later
* Erlang / OTP version 18 or later
  * Erlang needs to be built with the `--enable-dirty-schedulers` flag set
* A C compiler, such as gcc

### Dirty scheduler

As stated above, you need to build Erlang with dirty scheduler support
to use this library, which relies on dirty scheduler support in order
to handle long-running cryptography jobs, by moving them off the main
Erlang scheduler and letting the dirty schedulers handle the work.
This keeps the Erlang VM responsive.

## Installation

  1. Add `argon2_elixir` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:argon2_elixir, "~> 0.11"}]
    end
    ```

  2. Ensure `argon2_elixir` is started before your application:

    ```elixir
    def application do
      [applications: [:argon2_elixir]]
    end
    ```

  3. Configure `argon2_elixir` - see the documentation for Argon2.Stats for more details

## Use

Most users will just need to use the `hash_pwd_salt/2` and `verify_hash/3`
functions in the Argon2 module.

`hash_pwd_salt` generates a random salt and creates a hash from a password.

`verify_hash` takes a stored hash and a password and checks that the hash
is correct.

Please read the documentation for the Argon2 module for more information.

### License

Apache 2.0
