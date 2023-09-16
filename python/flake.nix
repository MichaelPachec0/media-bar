{
  description = "Python shell flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    # NOTE: this python specific.
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      flake = false;
    };
    mach-nix = {
      url = "github:davhau/mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };
  };
  outputs = {
    self,
    nixpkgs,
    mach-nix,
    flake-utils,
    ...
  }: let
    pyVersion = "python39";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          system = "${system}";
        };
        mach = import mach-nix {
          inherit pkgs;
        };

        pyEnv = mach.mkPython {
          python = pyVersion;
          requirements = pkgs.lib.strings.concatStringsSep "\n" (
            pkgs.lib.strings.splitString "\n" (
              builtins.readFile ./requirements.txt
            )
            ++ ["lockfile" "pip" "pygobject"]
          );
        };
      in {
        devShells.default = pkgs.mkShellNoCC {
          packages = [pyEnv ] ++ (with pkgs; [
          nodejs-slim_20
          ]);
          shellHook = ''
            export PYTHONPATH="${pyEnv}/bin/python"
          '';
        };
      }
    );
}
