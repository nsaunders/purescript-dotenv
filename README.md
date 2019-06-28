# purescript-dotenv ![Build Status](https://img.shields.io/travis/nicholassaunders/purescript-dotenv.svg) [![purescript-dotenv on Pursuit](https://pursuit.purescript.org/packages/purescript-dotenv/badge)](https://pursuit.purescript.org/packages/purescript-dotenv)
## Load environment variables from a ```.env``` file.

According to [_The Twelve-Factor App_](https://12factor.net/config), configuration should be strictly separated from code and instead defined in environment variables. If you have found this best practice to be inconvenient, then you may want to give ```purescript-dotenv``` a try.

### Overview

By allowing a configuration file to be consumed through the [```purescript-node-process``` environment API](https://pursuit.purescript.org/packages/purescript-node-process/7.0.0/docs/Node.Process#v:getEnv), this library enables your application code to leverage environment variables in production while reducing the burden of setting them in development and test environments.

Simply place your ```.env``` configuration file in the root of your project (ensuring for security reasons not to commit it), and then call ```Dotenv.loadFile``` at the beginning of your program. Environment variable lookups throughout your program will then fall back to the values defined in ```.env```.

A ```.env``` file looks like this:

```
DB_HOST=127.0.0.1
DB_NAME=myappdb
DB_CONNECTION_STRING=postgresql://$(whoami):${DB_PASS}@${DB_HOST}/${DB_NAME}
```

_Note: `DB_CONNECTION_STRING` in the above example demonstrates command and variable substitution. `$(whoami)` will
resolve to the result of running the [`whoami`](http://man7.org/linux/man-pages/man1/whoami.1.html) command, while
`${DB_PASS}` will resolve to the value of the `DB_PASS` environment variable (which also could have been set elsewhere in
the `.env` file)._

### Example
To run the [example](example/Main.purs) using [Pulp](https://github.com/purescript-contrib/pulp):
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
