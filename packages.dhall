let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.10-20230802/packages.dhall
        sha256:7304ec70da54602347b6dfeaf80121a2c35330e709234f0eb1d66406be6b5b58

in  upstream
  with node-fs.version = "v9.1.0"