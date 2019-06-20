let mkPackage =
      https://raw.githubusercontent.com/purescript/package-sets/master/src/mkPackage.dhall sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/master/src/packages.dhall sha256:ff6cc06a2aa5e94c7cfc804cca222112ce08117755a356e7ea33a4b4f71943de

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
