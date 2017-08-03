# Argon2

Argon2 password hashing for Elixir.

[Argon2](https://github.com/P-H-C/phc-winner-argon2) is the official winner of the
Password Hashing Competition, a several year project to identify a successor to
Bcrypt / Pbkdf2 / Scrypt password hashing methods.

This library can be used on its own, or it can be used together
with [Comeonin](https://hexdocs.pm/comeonin/api-reference.html),
which provides a higher-level api.

## Requirements

* Elixir version 1.4 or later
* Erlang / OTP version 18 or later
  * Erlang (< 20) needs to be built with the `--enable-dirty-schedulers` flag set
  * Erlang 20 has dirty schedulers enabled by default
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
      [{:argon2_elixir, "~> 1.2"}]
    end
    ```

  2. Configure `argon2_elixir` - see the documentation for Argon2.Stats for more details

If you are updating an existing application, you might need to add `:argon2_elixir`
to your list of applications. In most cases, this will not be necessary.

## Use

Most users will just need to use the `hash_pwd_salt/2` and `verify_pass/3`
functions in the Argon2 module.

`hash_pwd_salt` generates a random salt and creates a hash from a password.

`verify_pass` takes a password and a stored hash and checks that the password
is correct.

There is also a `no_user_verify` function which can be used to make user
enumeration more difficult.

Please read the documentation for the Argon2 module for more information.

### License

Apache 2.0. Please read the argon2/LICENSE file for more details about the Argon2 license.
