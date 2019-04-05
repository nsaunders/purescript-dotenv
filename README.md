# purescript-node-dotenv ![Build Status](https://img.shields.io/travis/nicholassaunders/purescript-node-dotenv.svg)
## Load environment variables from a ```.env``` file.

This is a lightweight clone of other dotenv projects like [this Haskell version](https://github.com/stackbuilders/dotenv-hs) or [this JavaScript version](https://github.com/motdotla/dotenv#readme).

For those unfamiliar, in short, a ```.env``` file looks like this:

```
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3131
DATABASE_USER=happydude
DATABASE_PASS=password
```

Simply drop the ```.env``` file in the root of your project (ensuring for security reasons not to commit it), and then call ```Dotenv.loadFile``` before any environment variable lookups.
