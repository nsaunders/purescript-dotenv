{ sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
, name =
    "dotenv"
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
