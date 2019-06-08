let mkPackage =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.13.0-20190607/src/mkPackage.dhall sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.13.0-20190607/src/packages.dhall sha256:96b28e434b8a62caea5f10376b4f7dc1736a668592cabe914f117ecf5673c2ff

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
