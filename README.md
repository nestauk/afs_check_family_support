# Rails Project Template

This is a template for creating a new Rails application including some of our
defaults.

When setting up a new project, you can copy this to get started a bit quicker.

## Development Principles

### Embrace the frameworks
Rails has well established conventions. We should 'embrace the framework',
using the conventional approach most of the time, even when we might personally
favour a different approach.

### Keep it simple
Resist the temptation to over-engineer. An incremental migration to a new
platform brings significant complexity; we should work to minimise that
complexity. Start with the simplest thing that works and iterate if required.

## Prequisites

This project requires [docker](https://www.docker.com/) to be installed.

## Setup

Copy the template `.env.template` to `.env`:
```shell
cp .env.template .env
```
You may need to update some of the values in the `.env` file.

Build the docker image:
```shell
./do build
```

Start the docker server:
```shell
./do up
```

Setup the database and seed the default data
```shell
./do rails db:migrate db:seed
```

The local development server will now be available at http://127.0.0.1:3000.

You can connect to the the PostgreSQL database at 127.0.0.1:5433 using `pgsql`
and `password` as the username and password.

All emails sent by the system will be sent to MailHog, http://127.0.0.1:8025.

## Testing and Coding Standards

Run the coding standards:
```shell
./do cs
```

Run the unit and integration tests:
```shell
./do test
```

Run the system tests:
```
./do test:system
```

### Running commands

Run a command using the `./do` script:
```shell
./do run ruby --version
```

Run a rails command (this is an alias of `./do run bin/rails`):
```shell
./do rails test
```

Run a rake command (this is an alias of `./do run bin/rake`):
```shell
./do rake standard
```

For more information on the commands, see the `do` script or run:
```shell
./do help
```