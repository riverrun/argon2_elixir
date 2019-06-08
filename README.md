# Argon2

[![Hex.pm Version](http://img.shields.io/hexpm/v/argon2_elixir.svg)](https://hex.pm/packages/argon2_elixir)
[![Build Status](https://travis-ci.com/riverrun/argon2_elixir.svg?branch=master)](https://travis-ci.com/riverrun/argon2_elixir)

Argon2 password hashing library for Elixir.

[Argon2](https://github.com/P-H-C/phc-winner-argon2) is the official winner
of the [Password Hashing Competition](https://password-hashing.net/),
a several year project to identify a successor to Bcrypt / Pbkdf2 / Scrypt
password hashing methods.

## Changes in version 2

In version 2.0, argon2_elixir has been updated to implement the Comeonin
and Comeonin.PasswordHash behaviours.

It now has the following two additional convenience functions:

* `add_hash/2`
  * same as Comeonin.Argon2.add_hash in Comeonin version 4
  * hashes a password and returns a map with the password hash
* `check_pass/3`
  * same as Comeonin.Argon2.check_pass in Comeonin version 4
  * takes a user struct and password as input and verifies the password

## Installation

1. Add `argon2_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:argon2_elixir, "~> 2.0"}]
end
```

2. Configure `argon2_elixir` - see the documentation for
[`Argon2.Stats`](https://hexdocs.pm/argon2_elixir/Argon2.Stats.html) for more details


## Comeonin wiki

See the [Comeonin wiki](https://github.com/riverrun/comeonin/wiki) for more
information on the following topics:

* [algorithms](https://github.com/riverrun/comeonin/wiki/Choosing-the-password-hashing-algorithm)
* [requirements](https://github.com/riverrun/comeonin/wiki/Requirements)
* [deployment](https://github.com/riverrun/comeonin/wiki/Deployment)
  * including information about using Docker
* [references](https://github.com/riverrun/comeonin/wiki/References)

## Contributing

There are many ways you can contribute to the development of this library, including:

* reporting issues
* improving documentation
* sharing your experiences with others
* [making a financial contribution](#donations)

## Donations

First of all, I would like to emphasize that this software is offered
free of charge. However, if you find it useful, and you would like to
buy me a cup of coffee, you can do so at [paypal](https://www.paypal.me/alovedalongthe).

### Documentation

http://hexdocs.pm/argon2_elixir

### License

Apache 2.0. Please read the argon2/LICENSE file for more details about the Argon2 license.
