let mkPackage =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.13.0-20190626/src/mkPackage.dhall sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.0-20210324/packages.dhall sha256:b4564d575da6aed1c042ca7936da97c8b7a29473b63f4515f09bb95fae8dddab

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
