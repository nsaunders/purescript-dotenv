{ name = "dotenv"
, license = "MIT"
, repository = "https://github.com/nsaunders/purescript-dotenv.git"
, dependencies =
  [ "aff"
  , "arrays"
  , "control"
  , "effect"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "lists"
  , "maybe"
  , "node-buffer"
  , "node-child-process"
  , "node-fs-aff"
  , "node-process"
  , "parsing"
  , "prelude"
  , "run"
  , "strings"
  , "sunde"
  , "transformers"
  , "tuples"
  , "typelevel-prelude"
  ]
, sources = [ "src/**/*.purs" ]
, packages = ./packages.dhall
}
