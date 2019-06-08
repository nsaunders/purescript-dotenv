let mkPackage =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.12.5-20190525/src/mkPackage.dhall sha256:0b197efa1d397ace6eb46b243ff2d73a3da5638d8d0ac8473e8e4a8fc528cf57

let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/psc-0.12.5-20190525/src/packages.dhall sha256:d52b72daa09ca9eca2d62744ea051177773cfaec4303cb23b4bc1b156344eed5

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
