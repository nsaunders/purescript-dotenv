# purescript-dotenv ![Build Status](https://img.shields.io/travis/nicholassaunders/purescript-dotenv.svg) [![purescript-dotenv on Pursuit](https://pursuit.purescript.org/packages/purescript-dotenv/badge)](https://pursuit.purescript.org/packages/purescript-dotenv)
## Load environment variables from a ```.env``` file.

<img src="https://raw.githubusercontent.com/nsaunders/purescript-dotenv/master/img/readme.png" alt="purescript-dotenv" align="right" />

According to [_The Twelve-Factor App_](https://12factor.net/config), configuration should be strictly separated from code and instead defined in environment variables. If you have found this best practice to be inconvenient, then you may want to give ```purescript-dotenv``` a try.

By allowing a configuration file to be consumed through the [`purescript-node-process` environment API](https://pursuit.purescript.org/packages/purescript-node-process/7.0.0/docs/Node.Process#v:getEnv), this library enables your application code to leverage environment variables in production while reducing the burden of setting them in development and test environments.

Simply place your `.env` configuration file in the root of your project (ensuring for security reasons not to commit it), and then call `Dotenv.loadFile` at the beginning of your program. Environment variable lookups throughout your program will then fall back to the values defined in `.env`.

### Configuration Format

The `.env` file may generally define one environment variable setting per line in the format `VARIABLE_NAME=value`. Here's a trivial example:

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
SUBJECT="The #1 reason you're not rich"
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

The stdout of a command can also be interpolated into a setting value using the `$(command)` syntax. The following example varies from the variable substitution example above by interpolating the output of the [`whoami`](http://man7.org/linux/man-pages/man1/whoami.1.html) command into the database connection string instead of a `DB_USER` setting:

```
DB_HOST=127.0.0.1
DB_NAME=myappdb
DB_CONN_STR=postgresql://$(whoami):${DB_PASS}@${DB_HOST}/${DB_NAME}
```

For a complete specification of parsing rules, please see the [parser tests](test/Parse.purs).

### Example
To run the example ([code](example/Main.purs), [`.env`](.env)) using [Pulp](https://github.com/purescript-contrib/pulp):
```
pulp run -I example
```
Or using [Spago](https://github.com/spacchetti/spago):
```
spago run -p example/Main.purs
```

### Other ```dotenv``` implementations
* Haskell: [stackbuilders/dotenv-hs](https://github.com/stackbuilders/dotenv-hs)
* Haskell: [pbrisbin/load-env](https://github.com/pbrisbin/load-env)
* JavaScript: [motdotla/dotenv](http://github.com/motdotla/dotenv)
* Python: [theskumar/python-dotenv](https://github.com/theskumar/python-dotenv)
* Ruby: [bkeepers/dotenv](https://github.com/bkeepers/dotenv)
