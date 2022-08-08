let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.2-20220706/packages.dhall
        sha256:7a24ebdbacb2bfa27b2fc6ce3da96f048093d64e54369965a2a7b5d9892b6031

in upstream
  with parsing.version = "v10.0.0"
  with sunde =
    { dependencies = [ "aff", "effect", "node-child-process", "prelude" ]
    , repo = "https://github.com/justinwoo/purescript-sunde.git"
    , version = "v3.0.0"
    }
