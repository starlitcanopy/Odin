{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    let
      perSystem =
        system:
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system}.extend inputs.self.overlays.default;
        in
        {
          packages = { inherit (pkgs) odin; };
        };
    in
    {
      overlays.default = final: prev: {
        odin = prev.odin.overrideAttrs (_: {
          version = "unstable-2025-05-19";
          patches = [ ]; # I have already applied the darwin patch
          src = ./.;
        });
      };
    }
    // inputs.flake-utils.lib.eachSystem (with inputs.flake-utils.lib.system; [
      x86_64-linux
    ]) perSystem;
}
