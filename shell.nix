let
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/23.05.tar.gz";
  }) {};

  # To update to a newer version of easy-purescript-nix:
  # 1. Obtain the commit hash <rev> via `curl https://api.github.com/repos/justinwoo/easy-purescript-nix/commits/master`.
  # 2. Obtain the sha256 hash <sha256> via `nix-prefetch-url --unpack https://github.com/justinwoo/easy-purescript-nix/archive/<rev>.tar.gz`.
  # 3. Update the <rev> and <sha256> below.
  pursPkgs = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "5dcea83eecb56241ed72e3631d47e87bb11e45b9";
    sha256 = "1diwnyj247bsyhgymprpc0cdxkkzdvnxx4s2kw2fiig6xkcb4jwd";
  }) {inherit pkgs;};
in
  pkgs.stdenv.mkDerivation {
    name = "dotenv";
    buildInputs = with pursPkgs; [
      purs
      spago
      pulp
      purs-tidy

      pkgs.nodePackages.bower
      pkgs.nodejs_18
    ];
  }
