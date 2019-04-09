# purescript-node-dotenv ![Build Status](https://img.shields.io/travis/nicholassaunders/purescript-node-dotenv.svg)
## Load environment variables from a ```.env``` file.

This is a lightweight clone of various dotenv projects like
[this Haskell version](https://github.com/stackbuilders/dotenv-hs) or
[this JavaScript version](https://github.com/motdotla/dotenv#readme).

### Overview

A ```.env``` file looks like this:

```
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3131
DATABASE_USER=happydude
DATABASE_PASS=password
```

Simply drop the ```.env``` file in the root of your project (ensuring for security reasons not to commit it), and then
call ```Dotenv.loadFile``` at the beginning of your program. Environment variable lookups will then fall back to the
values defined in ```.env```.

### Example
To run the [example](example/Main.purs):
```
pulp run -I example --main Example.Main
```
