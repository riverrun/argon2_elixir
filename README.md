# Argon2

[![Build Status](https://travis-ci.com/riverrun/argon2_elixir.svg?branch=master)](https://travis-ci.com/riverrun/argon2_elixir)
[![Hex Version](https://img.shields.io/hexpm/v/argon2_elixir.svg)](https://hex.pm/packages/argon2_elixir)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/argon2_elixir/)
[![Total Download](https://img.shields.io/hexpm/dt/argon2_elixir.svg)](https://hex.pm/packages/argon2_elixir)
[![License](https://img.shields.io/hexpm/l/argon2_elixir.svg)](https://github.com/riverrun/argon2_elixir/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/riverrun/argon2_elixir.svg)](https://github.com/riverrun/argon2_elixir/commits/master)


Argon2 password hashing library for Elixir.

[Argon2](https://github.com/P-H-C/phc-winner-argon2) is the official winner
of the [Password Hashing Competition](https://password-hashing.net/),
a several year project to identify a successor to Bcrypt / Pbkdf2 / Scrypt
password hashing methods.

## Installation

Add `:argon2_elixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:argon2_elixir, "~> 2.0"}
  ]
end
```

Configure `argon2_elixir` - see the documentation for
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

### Documentation

http://hexdocs.pm/argon2_elixir

## Copyright and License

Copyright (c) 2016 David Whitlock

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
