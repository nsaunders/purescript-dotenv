# purescript-dotenv [![Build](https://github.com/nsaunders/purescript-dotenv/workflows/CI/badge.svg)](https://github.com/nsaunders/purescript-dotenv/actions/workflows/ci.yml) [![Latest release](http://img.shields.io/github/release/nsaunders/purescript-dotenv.svg)](https://github.com/nsaunders/purescript-dotenv/releases) [![PureScript registry](https://img.shields.io/badge/dynamic/json?color=informational&label=registry&query=%24.dotenv.version&url=https%3A%2F%2Fraw.githubusercontent.com%2Fpurescript%2Fpackage-sets%2Fmaster%2Fpackages.json)](https://github.com/purescript/registry) [![purescript-dotenv on Pursuit](https://pursuit.purescript.org/packages/purescript-dotenv/badge)](https://pursuit.purescript.org/packages/purescript-dotenv)
## Load environment variables from a `.env` file.

<img src="https://github.com/nsaunders/purescript-dotenv/raw/master/meta/img/readme.png" alt="purescript-dotenv" align="right" />

According to [_The Twelve-Factor App_](https://12factor.net/config), configuration should be strictly separated from code and instead defined in environment variables. If you have found this best practice to be inconvenient in your dev environment, then you may want to give `purescript-dotenv` a try.

By effectively allowing a configuration file to be consumed through the [`purescript-node-process` environment API](https://pursuit.purescript.org/packages/purescript-node-process/7.0.0/docs/Node.Process#v:getEnv), this library enables your application code to leverage environment variables in production while easing the burden of setting them in development and test environments.

Simply place your `.env` configuration file in the root of your project (ensuring for security reasons not to commit it), and then call `Dotenv.loadFile` at the beginning of your program. Environment variable lookups throughout your program will then fall back to the values defined in `.env`.

### Installation

via [spago](https://github.com/spacchetti/spago):
```
spago install dotenv
```

### Usage

First, place a `.env` file in the root of your project directory. See the [Configuration Format](#configuration-format) section for more information.

Next, import the `Dotenv` module at the entry point of your program (i.e. `Main.purs`):

```purescript
import Dotenv (loadFile) as Dotenv
```

The `loadFile` function runs in [`Aff`](https://pursuit.purescript.org/packages/purescript-aff/5.1.1/docs/Effect.Aff#t:Aff), so you will also need to import something like [`launchAff_`](https://pursuit.purescript.org/packages/purescript-aff/5.1.1/docs/Effect.Aff#v:launchAff_):

```purescript
import Effect.Aff (launchAff_)
```

Finally, call the `loadFile` function from your `main` function before the rest of your program logic:

```purescript
main :: Effect Unit
main = launchAff_ do
  Dotenv.loadFile
  liftEffect do
    testVar <- lookupEnv "TEST_VAR"
    logShow testVar
```

### Configuration Format

The `.env` file may generally define one environment variable setting per line in the format `VARIABLE_NAME=value`. For example:

```
EMAIL_FROM=noreply@my.app
EMAIL_SUBJECT=Testing
EMAIL_BODY=It worked!
```

#### Comments

Text prefixed with `#` is recognized as a comment and ignored. A comment may appear on its own line or at the end of a line containing a setting. For example:

```
# Application Settings

GREETING=Hello, Sailor! # A friendly greeting
```

#### Quoted Values

Setting values may be wrapped with single or double quotes. This is required when the value contains a `#` character so that it is not treated as a comment. It is also necessary when the value includes line breaks. For example:

```
SUBJECT="This one weird trick will double your productivity"
MESSAGE="Dear friend,

Insert compelling message here.

Sincerely,
Bob"
```

#### Variable Substitution

The value of an environment variable (or another setting) can be interpolated into a setting value using the `${VARIABLE_NAME}` syntax. For example:

```
DB_HOST=127.0.0.1
DB_NAME=myappdb
DB_USER=dbuser
DB_CONN_STR=postgresql://${DB_USER}:${DB_PASS}@${DB_HOST}/${DB_NAME}
```

#### Command Substitution

The standard output of a command can also be interpolated into a setting value using the `$(command)` syntax. In the following example, the output of the [`whoami`](http://man7.org/linux/man-pages/man1/whoami.1.html) command is interpolated into the database connection string:

```
DB_HOST=127.0.0.1
DB_NAME=myappdb
DB_CONN_STR=postgresql://$(whoami):${DB_PASS}@${DB_HOST}/${DB_NAME}
```

#### Additional Parsing Rules

For a complete specification of parsing rules, please see the [parser tests](test/Parser.purs).

### Examples

To run the [examples](./examples), clone the repository and run one of the following depending on your package manager and build tool, replacing `<example-name>` with the name of one of the examples.

[spago](https://github.com/spacchetti/spago):
```
spago run -p example/<example-name>.purs -m Example.<example-name>
```

### Other ```dotenv``` implementations
* Haskell: [stackbuilders/dotenv-hs](https://github.com/stackbuilders/dotenv-hs)
* Haskell: [pbrisbin/load-env](https://github.com/pbrisbin/load-env)
* JavaScript: [motdotla/dotenv](http://github.com/motdotla/dotenv)
* Python: [theskumar/python-dotenv](https://github.com/theskumar/python-dotenv)
* Ruby: [bkeepers/dotenv](https://github.com/bkeepers/dotenv)
