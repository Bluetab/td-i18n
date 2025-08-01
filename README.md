# Truedat Internationalization

TdI18n is a back-end service that supports the internationalization and
localization of messages used by Truedat.

## Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development and testing purposes. See deployment for notes on
how to deploy the project on a live system.

### Prerequisites

Install dependencies with `mix deps.get`

To start your Phoenix server:

### Installing

- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- Now you can visit [`localhost:4003`](http://localhost:4003) from your browser.

## Running the tests

Run all aplication tests with `mix test`

## Environment variables

### SSL conection

- DB_SSL: boolean value, to enable TSL config, by default is false.
- DB_SSL_CACERTFILE: path of the certification authority cert file "/path/to/ca.crt".
- DB_SSL_VERSION: available versions are tlsv1.2, tlsv1.3 by default is tlsv1.2.
- DB_SSL_CLIENT_CERT: Path to the client SSL certificate file.
- DB_SSL_CLIENT_KEY: Path to the client SSL private key file.
- DB_SSL_VERIFY: This option specifies whether certificates are to be verified.

## Deployment

Ready to run in production? Please [check our deployment
guides](http://www.phoenixframework.org/docs/deployment).

## Built With

- [Phoenix](http://www.phoenixframework.org/) - Web framework
- [Ecto](http://www.phoenixframework.org/) - Phoenix and Ecto integration
- [Postgrex](http://hexdocs.pm/postgrex/) - PostgreSQL driver for Elixir
- [Cowboy](https://ninenines.eu) - HTTP server for Erlang/OTP
- [Credo](http://credo-ci.org/) - Static code analysis tool for the Elixir
  language
- [Guardian](https://github.com/ueberauth/guardian) - Authentication library
- [ExMachina](https://hex.pm/packages/ex_machina) - Create test data for Elixir
  applications

## Authors

- **Bluetab Solutions Group, SL** - _Initial work_ -
  [Bluetab](http://www.bluetab.net)

See also the list of [contributors](https://github.com/bluetab/td-i18n) who
participated in this project.

## License

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see https://www.gnu.org/licenses/.

In order to use this software, it is necessary that, depending on the type of
functionality that you want to obtain, it is assembled with other software whose
license may be governed by other terms different than the GNU General Public
License version 3 or later. In that case, it will be absolutely necessary that,
in order to make a correct use of the software to be assembled, you give
compliance with the rules of the concrete license (of Free Software or Open
Source Software) of use in each case, as well as, where appropriate, obtaining
of the permits that are necessary for these appropriate purposes.
