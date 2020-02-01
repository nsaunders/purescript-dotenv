{ sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
, name =
    "dotenv"
, license = "MIT"
, repository = "https://github.com/nsaunders/purescript-dotenv.git"
, dependencies =
    [ "console"
    , "effect"
    , "node-fs-aff"
    , "node-process"
    , "parsing"
    , "psci-support"
    , "run"
    , "spec"
    , "sunde"
    ]
, packages =
    ./packages.dhall
}
